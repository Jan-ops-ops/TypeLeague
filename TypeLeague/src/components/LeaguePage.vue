<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { supabase, supabaseUrl, supabaseAnonKey } from "../supabase";
import Gameboard from "./gameboard.vue";

const view = ref('lobby');
const playerElo = ref(1000);
const playerLanguageId = ref(1);
const isSearching = ref(false);
const isHost = ref(false);
const gameText = ref("");
const countdown = ref<number | null>(null);

const opponentName = ref("Gegner");
const playerProgress = ref(0);
const opponentProgress = ref(0);
const playerStats = ref<any>(null);
const roomId = ref("");
const opponentFinished = ref(false);
const opponentDisconnected = ref(false);
const currentMatchId = ref<string | null>(null);
const currentUserId = ref<string | null>(null);

const lastGames = ref<{ opponent: string; change: string; win: boolean }[]>([]);

let queueSub: any = null;
let gameChannel: any = null;
let countdownTimer: ReturnType<typeof setTimeout> | null = null;

// ---- League helpers ----
const getDifficultyFromElo = (elo: number): number => {
  if (elo < 1200) return 1;
  if (elo < 1400) return 2;
  if (elo < 1600) return 3;
  if (elo < 1800) return 4;
  return 5;
};

const getLeagueName = (elo: number): string => {
  if (elo < 1200) return 'Bronze';
  if (elo < 1400) return 'Silver';
  if (elo < 1600) return 'Gold';
  if (elo < 1800) return 'Platinum';
  return 'Diamond';
};

const getLeagueRange = (elo: number): { min: number; max: number } => {
  if (elo < 1200) return { min: 0,    max: 1199 };
  if (elo < 1400) return { min: 1200, max: 1399 };
  if (elo < 1600) return { min: 1400, max: 1599 };
  if (elo < 1800) return { min: 1600, max: 1799 };
  return               { min: 1800, max: 9999  };
};

const leagueName = computed(() => getLeagueName(playerElo.value));

// ---- Data loading ----
const loadUserData = async () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  if (localUser.name) {
    const { data } = await supabase
      .from('users').select('userid, elo, fk_languagesid').eq('username', localUser.name).single();
    if (data) {
      playerElo.value = data.elo;
      playerLanguageId.value = data.fk_languagesid || 1;
      currentUserId.value = data.userid;
    }
  }
};

const loadLastGames = async () => {
  if (!currentUserId.value) return;
  const { data } = await supabase
    .from('plays')
    .select('elo_change, opponent_username')
    .eq('fk_userid', currentUserId.value)
    .not('elo_change', 'is', null)
    .order('playid', { ascending: false })
    .limit(5);
  if (data) {
    lastGames.value = data.map(p => ({
      opponent: p.opponent_username || '?',
      change: p.elo_change > 0 ? `+${p.elo_change}` : `${p.elo_change}`,
      win: p.elo_change > 0
    }));
  }
};

// Returns league ID (1–5) matching the inserted order: Bronze=1, Silver=2, …
const getLeagueId = (elo: number): number => {
  if (elo < 1200) return 1;
  if (elo < 1400) return 2;
  if (elo < 1600) return 3;
  if (elo < 1800) return 4;
  return 5;
};

// ---- Game text (host generates, sends to opponent via queue update) ----
const generateGameText = async (): Promise<string> => {
  const difficulty = getDifficultyFromElo(playerElo.value);
  const { data: wordData } = await supabase
    .from('wordlist').select('word')
    .eq('difficulty', difficulty).eq('fk_languagesid', playerLanguageId.value).single();
  if (!wordData?.word) return '';
  const words: string[] = wordData.word;
  return Array.from({ length: 15 }, () =>
    words[Math.floor(Math.random() * words.length)]
  ).join(' ');
};

// ---- Synced countdown ----
// Both players call startCountdown with the same startAt epoch ms → identical display.
const startCountdown = (startAt: number) => {
  const tick = () => {
    const remaining = Math.ceil((startAt - Date.now()) / 1000);
    if (remaining <= 0) {
      countdown.value = null;
    } else {
      countdown.value = remaining;
      countdownTimer = setTimeout(tick, 100);
    }
  };
  tick();
};

// ---- Matchmaking ----
const toggleReady = async () => {
  if (isSearching.value) { cancelSearch(); return; }
  isSearching.value = true;
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  const range = getLeagueRange(playerElo.value);

  const { data: opponent } = await supabase
    .from('matchmaking_queue').select('*')
    .eq('status', 'waiting').neq('username', localUser.name)
    .gte('elo', range.min).lte('elo', range.max)
    .limit(1).maybeSingle();

  if (opponent) {
    const generatedId = "room_" + Math.random().toString(36).substr(2, 9);
    roomId.value = generatedId;
    opponentName.value = opponent.username;
    isHost.value = true;

    const text = await generateGameText();
    gameText.value = text;
    await supabase.from('matchmaking_queue')
      .update({ status: 'matched', room_id: generatedId, game_text: text, host_username: localUser.name })
      .eq('id', opponent.id);

    await startMatch(generatedId);
  } else {
    const { data: myRequest } = await supabase.from('matchmaking_queue')
      .insert({ username: localUser.name, elo: playerElo.value, status: 'waiting' })
      .select().single();

    if (myRequest) {
      queueSub = supabase.channel('queue_' + myRequest.id)
        .on('postgres_changes', {
          event: 'UPDATE', schema: 'public', table: 'matchmaking_queue',
          filter: `id=eq.${myRequest.id}`
        }, async (payload) => {
          if (payload.new.status === 'matched') {
            roomId.value = payload.new.room_id;
            gameText.value = payload.new.game_text || '';
            opponentName.value = payload.new.host_username || 'Host';
            isHost.value = false;
            await startMatch(payload.new.room_id);
            queueSub.unsubscribe();
          }
        }).subscribe();
    }
  }
};

const cancelSearch = async () => {
  isSearching.value = false;
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  await supabase.from('matchmaking_queue').delete().eq('username', localUser.name);
  if (queueSub) queueSub.unsubscribe();
};

// ---- Match lifecycle ----
const startMatch = async (id: string) => {
  opponentFinished.value = false;
  opponentDisconnected.value = false;
  playerStats.value = null;
  countdown.value = 3; // hide gameboard immediately, before channel subscribes
  view.value = 'arena';
  playerProgress.value = 0;
  opponentProgress.value = 0;

  gameChannel = supabase.channel(id);
  gameChannel
    .on('broadcast', { event: 'progress' }, (payload: any) => {
      opponentProgress.value = payload.payload.progress;
    })
    .on('broadcast', { event: 'countdown_sync' }, (payload: any) => {
      if (!isHost.value) {
        startCountdown(payload.payload.start_at);
        currentMatchId.value = payload.payload.match_id || null;
      }
    })
    .on('broadcast', { event: 'match_finished' }, () => {
      // Opponent finished → we lose immediately, no need to keep typing
      opponentFinished.value = true;
      applyEloAndShowResult(false);
    })
    .on('broadcast', { event: 'disconnect' }, () => {
      opponentDisconnected.value = true;
      if (view.value === 'arena') applyEloAndShowResult(true);
    })
    .subscribe(async () => {
      if (isHost.value) {
        // Create match record, then after 600ms broadcast start time + matchId to non-host
        const { data: matchData } = await supabase
          .from('matches')
          .insert({ fk_leagueid: getLeagueId(playerElo.value) })
          .select('matchid').single();
        currentMatchId.value = matchData?.matchid || null;

        setTimeout(() => {
          const startAt = Date.now() + 3000;
          startCountdown(startAt);
          gameChannel.send({
            type: 'broadcast', event: 'countdown_sync',
            payload: { start_at: startAt, match_id: currentMatchId.value }
          });
        }, 600);
      }
    });
};

const applyEloAndShowResult = async (win: boolean) => {
  if (view.value === 'results') return;
  isSearching.value = false;
  const eloChange = win ? 25 : -15;
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');

  await supabase.from('users')
    .update({ elo: playerElo.value + eloChange }).eq('username', localUser.name);
  playerElo.value += eloChange;

  // Save play record so it shows up in "Letzte Spiele"
  if (currentMatchId.value && currentUserId.value) {
    await supabase.from('plays').insert({
      fk_userid: currentUserId.value,
      fk_matchid: currentMatchId.value,
      opponent_username: opponentName.value,
      elo_change: eloChange,
      real_time_seconds: playerStats.value?.realTime ?? null,
      mistakes: playerStats.value?.mistakes ?? null,
      adjusted_time: playerStats.value?.adjustedTime ?? null,
      wpm: playerStats.value?.wpm ?? null,
    });
    if (win) {
      await supabase.from('matches')
        .update({ winner_id: currentUserId.value })
        .eq('matchid', currentMatchId.value);
    }
  }

  view.value = 'results';
  await loadLastGames();
};

const handleProgress = (index: number) => {
  if (countdown.value !== null) return;
  const progress = (index / gameText.value.length) * 100;
  playerProgress.value = progress;
  if (gameChannel) {
    gameChannel.send({ type: 'broadcast', event: 'progress', payload: { progress } });
  }
};

const onFinished = async (stats: any) => {
  if (view.value === 'results') return;
  playerStats.value = stats;
  isSearching.value = false;
  if (gameChannel) {
    gameChannel.send({ type: 'broadcast', event: 'match_finished', payload: {} });
  }
  await applyEloAndShowResult(!opponentFinished.value);
};

// ---- Disconnect on page close/refresh ----
const handleBeforeUnload = () => {
  if (view.value !== 'arena') return;

  // Tell opponent we left
  if (gameChannel) {
    gameChannel.send({ type: 'broadcast', event: 'disconnect', payload: {} });
  }

  // Deduct elo for the disconnecting player using keepalive fetch (survives page close)
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  if (localUser.name) {
    fetch(
      `${supabaseUrl}/rest/v1/users?username=eq.${encodeURIComponent(localUser.name)}`,
      {
        method: 'PATCH',
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': `Bearer ${supabaseAnonKey}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify({ elo: playerElo.value - 15 }),
        keepalive: true,
      }
    );
  }
};

onMounted(async () => {
  await loadUserData();
  await loadLastGames();
  window.addEventListener('beforeunload', handleBeforeUnload);
});

onUnmounted(() => {
  window.removeEventListener('beforeunload', handleBeforeUnload);
  if (countdownTimer) clearTimeout(countdownTimer);
  if (queueSub) queueSub.unsubscribe();
  if (gameChannel) gameChannel.unsubscribe();
});
</script>

<template>
  <div class="app-container">

    <!-- LOBBY -->
    <div v-if="view === 'lobby'" class="league-page">
      <aside class="side-panel">
        <div class="stats-card">
          <div class="elo-section">
            <span class="elo-label">{{ leagueName.toUpperCase() }} LEAGUE</span>
            <div class="elo-display">
              <span class="elo-value">{{ playerElo }}</span>
            </div>
          </div>
          <div class="recent-matches">
            <h4 class="matches-title">LETZTE SPIELE</h4>
            <div v-if="lastGames.length === 0" class="no-games">Noch keine Spiele</div>
            <div v-for="(game, index) in lastGames" :key="index" class="match-entry">
              <span class="opponent-name">{{ game.opponent }}</span>
              <span :class="['elo-change', game.win ? 'plus' : 'minus']">{{ game.change }}</span>
            </div>
          </div>
        </div>
      </aside>

      <main class="main-content">
        <div class="header-section">
          <h1 class="league-title">League Mode</h1>
          <div class="divider-main"></div>
        </div>
        <div class="matchmaking-container">
          <div class="matchmaking-card">
            <div class="box-content">
              <h3 class="box-title">Bereit für den Aufstieg?</h3>
              <p class="box-text">Klicke auf Ready, um einen Gegner auf deinem Niveau zu finden.</p>
            </div>
            <button class="ready-btn" :class="{ 'is-searching': isSearching }" @click="toggleReady">
              <span class="btn-text">{{ isSearching ? 'SEARCHING...' : 'READY!' }}</span>
            </button>
          </div>
          <p class="footer-description">Tritt gegen andere Legenden in Echtzeit an</p>
        </div>
      </main>
    </div>

    <!-- ARENA -->
    <div v-if="view === 'arena'" class="arena-container">

      <!-- Countdown overlay — blocks typing until 0 -->
      <div v-if="countdown !== null" class="countdown-overlay">
        <div class="countdown-number">{{ countdown }}</div>
        <div class="countdown-label">GET READY</div>
      </div>

      <div class="race-track">
        <div class="lane">
          <div class="lane-label">YOU ({{ playerProgress.toFixed(0) }}%)</div>
          <div class="bar-bg"><div class="bar-fill" :style="{ width: playerProgress + '%' }"></div></div>
        </div>
        <div class="lane">
          <div class="lane-label">{{ opponentName }} ({{ opponentProgress.toFixed(0) }}%)</div>
          <div class="bar-bg"><div class="bar-fill opponent-bar" :style="{ width: opponentProgress + '%' }"></div></div>
        </div>
      </div>

      <!-- Only mount Gameboard after countdown ends so keyboard input is blocked during countdown -->
      <Gameboard v-if="countdown === null" :key="gameText" :gametext="gameText" @progress="handleProgress" @finished="onFinished" />
    </div>

    <!-- RESULTS -->
    <div v-if="view === 'results'" class="results-screen">
      <div class="result-card">
        <template v-if="opponentDisconnected">
          <h1 class="win-text">VICTORY</h1>
          <p class="disconnect-msg">{{ opponentName }} has disconnected.</p>
        </template>
        <template v-else>
          <h1 :class="!opponentFinished ? 'win-text' : 'lose-text'">
            {{ !opponentFinished ? 'VICTORY' : 'DEFEAT' }}
          </h1>
        </template>

        <template v-if="playerStats">
          <p>Time: {{ playerStats.realTime.toFixed(2) }}s</p>
          <p v-if="playerStats.mistakes > 0" class="penalty-text">
            +{{ playerStats.mistakes * 3 }}s penalty ({{ playerStats.mistakes }} mistake{{ playerStats.mistakes > 1 ? 's' : '' }})
          </p>
          <p>Adjusted: {{ playerStats.adjustedTime.toFixed(2) }}s</p>
        </template>

        <p class="elo-res">New Rating: {{ playerElo }}</p>
        <button class="ready-btn" @click="view = 'lobby'">BACK TO LOBBY</button>
      </div>
    </div>

  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&display=swap');

.app-container { min-height: 100vh; width: 100vw; background-color: #0b0e14; overflow: hidden; display: flex; flex-direction: column; }
.league-page { font-family: 'Nunito', sans-serif; flex: 1; display: flex; color: #f8fafc; padding: 40px 60px; }
.side-panel { width: 280px; }
.stats-card { background: #1e293b; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); }
.elo-section { padding: 20px; }
.elo-label { display: block; font-size: 0.65rem; color: #64748b; font-weight: 800; letter-spacing: 1px; }
.elo-value { font-size: 2.2rem; font-weight: 900; color: #ff7e00; }
.recent-matches { padding: 0 15px 15px; }
.matches-title { font-size: 0.6rem; color: #475569; margin-bottom: 10px; font-weight: 900; }
.match-entry { background: rgba(11, 14, 20, 0.3); margin-bottom: 5px; padding: 8px 12px; border-radius: 6px; display: flex; justify-content: space-between; }
.plus { color: #10b981; }
.minus { color: #ef4444; }
.main-content { flex-grow: 1; padding-left: 50px; }
.league-title { color: #ff7e00; font-size: 3.5rem; font-weight: 900; }
.divider-main { height: 4px; background: #ff7e00; border-radius: 4px; margin: 5px 0 25px; }
.matchmaking-card { background: #1e293b; border-radius: 12px; padding: 25px 40px; display: flex; align-items: center; justify-content: space-between; }
.ready-btn { background: #ff7e00; border: none; color: #0b0e14; padding: 14px 30px; font-size: 1.2rem; font-weight: 900; border-radius: 8px; cursor: pointer; transition: 0.2s; }
.is-searching { background: #cc6600; animation: pulse 1.5s infinite; }

.arena-container { flex: 1; display: flex; flex-direction: column; align-items: center; padding: 40px; position: relative; }
.race-track { width: 100%; max-width: 800px; margin-bottom: 40px; }
.lane { margin-bottom: 20px; }
.lane-label { font-size: 0.8rem; font-weight: 800; color: #64748b; margin-bottom: 5px; }
.bar-bg { background: #1e293b; height: 12px; border-radius: 6px; overflow: hidden; }
.bar-fill { height: 100%; background: #ff7e00; transition: width 0.1s linear; }
.opponent-bar { background: #64748b; }

.countdown-overlay {
  position: absolute;
  inset: 0;
  background: rgba(11, 14, 20, 0.92);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 10;
}
.countdown-number {
  font-family: 'Nunito', sans-serif;
  font-size: 9rem;
  font-weight: 900;
  color: #ff7e00;
  line-height: 1;
  animation: pop 0.9s ease-out infinite;
}
.countdown-label {
  font-family: 'Nunito', sans-serif;
  font-size: 1rem;
  font-weight: 800;
  color: #64748b;
  letter-spacing: 4px;
  margin-top: 16px;
}

.results-screen { flex: 1; display: flex; justify-content: center; align-items: center; }
.result-card { background: #1e293b; padding: 50px; border-radius: 20px; text-align: center; border: 1px solid #ff7e00; }
.win-text { color: #10b981; font-size: 3rem; margin: 0 0 16px; }
.lose-text { color: #ef4444; font-size: 3rem; margin: 0 0 16px; }
.elo-res { color: #ff7e00; font-weight: 900; margin: 10px 0 25px; }
.penalty-text { color: #ef4444; font-size: 0.85rem; margin: 2px 0; }
.no-games { color: #475569; font-size: 0.75rem; padding: 8px 0; }
.disconnect-msg { color: #94a3b8; font-size: 0.9rem; margin-bottom: 16px; }

@keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }
@keyframes pop { 0% { transform: scale(1.15); opacity: 0.6; } 100% { transform: scale(1); opacity: 1; } }
</style>

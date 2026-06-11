<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { supabase, supabaseUrl, supabaseAnonKey } from "../supabase";
import Gameboard from "./gameboard.vue";

const router = useRouter();

const view = ref<'lobby' | 'arena' | 'results'>('lobby');
const playerElo = ref(1000);
const playerLanguageId = ref(1);
const isSearching = ref(false);
const isHost = ref(false);
const gameText = ref("");
const countdown = ref<number | null>(3);

const opponentName = ref("Gegner");
const playerProgress = ref(0);
const opponentProgress = ref(0);
const playerStats = ref<any>(null);
const roomId = ref("");
const opponentDisconnected = ref(false);
const currentMatchId = ref<string | null>(null);
const currentUserId = ref<string | null>(null);

const gracePeriodLeft = ref(0);
const opponentAdjustedTime = ref<number | null>(null);
const iFinishedFirst = ref(false);
const didWin = ref(false);
const countdownStarted = ref(false);

const lastGames = ref<{ opponent: string; change: string; win: boolean }[]>([]);

let queueSub: any = null;
let gameChannel: any = null;
let countdownTimer: ReturnType<typeof setTimeout> | null = null;
let gracePeriodTimer: ReturnType<typeof setInterval> | null = null;
let countdownFired = false;

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
const getLeagueRange = (elo: number) => {
  if (elo < 1200) return { min: 0,    max: 1199 };
  if (elo < 1400) return { min: 1200, max: 1399 };
  if (elo < 1600) return { min: 1400, max: 1599 };
  if (elo < 1800) return { min: 1600, max: 1799 };
  return               { min: 1800, max: 9999  };
};
const getLeagueId = (elo: number): number => {
  if (elo < 1200) return 1;
  if (elo < 1400) return 2;
  if (elo < 1600) return 3;
  if (elo < 1800) return 4;
  return 5;
};
const leagueName = computed(() => getLeagueName(playerElo.value));

const loadUserData = async () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  if (!localUser.name) return;
  const { data } = await supabase
    .from('users').select('userid, elo, fk_languagesid').eq('username', localUser.name).single();
  if (data) {
    playerElo.value = data.elo;
    playerLanguageId.value = data.fk_languagesid || 1;
    currentUserId.value = data.userid;

    const { data: level10Data } = await supabase
      .from('user_level')
      .select('completed')
      .eq('fk_userid', data.userid)
      .eq('fk_levelid', 10)
      .eq('completed', true)
      .maybeSingle();

    if (!level10Data) {
      await router.push('/roadmap');
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
      win: p.elo_change > 0,
    }));
  }
};

const generateUUID = (): string => {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    const r = Math.random() * 16 | 0;
    return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
};

const extractWords = (rows: any[]): string[] => {
  const words: string[] = [];
  for (const row of rows) {
    if (Array.isArray(row.word)) words.push(...row.word);
    else if (typeof row.word === 'string' && row.word.trim()) words.push(row.word.trim());
  }
  return words;
};

const generateGameText = async (): Promise<string> => {
  const difficulty = getDifficultyFromElo(playerElo.value);

  const { data: primary } = await supabase
    .from('wordlist').select('word')
    .eq('difficulty', difficulty)
    .eq('fk_languagesid', playerLanguageId.value);

  let words = extractWords(primary ?? []);

  if (words.length === 0 && playerLanguageId.value !== 1) {
    const { data: fallbackLang } = await supabase
      .from('wordlist').select('word')
      .eq('difficulty', difficulty)
      .eq('fk_languagesid', 1);
    words = extractWords(fallbackLang ?? []);
  }

  if (words.length === 0) {
    const { data: anyDiff } = await supabase
      .from('wordlist').select('word')
      .eq('fk_languagesid', 1);
    words = extractWords(anyDiff ?? []);
  }

  if (words.length === 0) return 'sun car tree home fast road bird cold wind book blue sky box map key door run hat old ice';

  return Array.from({ length: 15 }, () =>
    words[Math.floor(Math.random() * words.length)]
  ).join(' ');
};

const triggerLocalCountdown = () => {
  if (countdownTimer) clearTimeout(countdownTimer);
  countdownStarted.value = true;
  countdown.value = 3;
  let count = 3;
  const tick = () => {
    count--;
    if (count <= 0) {
      countdown.value = null;
    } else {
      countdown.value = count;
      countdownTimer = setTimeout(tick, 1000);
    }
  };
  countdownTimer = setTimeout(tick, 1000);
};

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
          filter: `id=eq.${myRequest.id}`,
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

const startMatch = async (id: string) => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  opponentDisconnected.value = false;
  opponentAdjustedTime.value = null;
  iFinishedFirst.value = false;
  gracePeriodLeft.value = 0;
  playerStats.value = null;
  didWin.value = false;
  countdownStarted.value = false;
  countdown.value = 3;
  countdownFired = false;
  view.value = 'arena';
  playerProgress.value = 0;
  opponentProgress.value = 0;

  gameChannel = supabase.channel(id, {
    config: { presence: { key: localUser.name } },
  });

  gameChannel
    .on('presence', { event: 'sync' }, () => {
      const state = gameChannel.presenceState();
      if (Object.keys(state).length >= 2 && isHost.value && !countdownFired) {
        countdownFired = true;
        currentMatchId.value = crypto.randomUUID();
        gameChannel.send({
          type: 'broadcast', event: 'start_countdown',
          payload: { match_id: currentMatchId.value },
        });
        triggerLocalCountdown();
      }
    })
    .on('broadcast', { event: 'start_countdown' }, (payload: any) => {
      if (!isHost.value) {
        currentMatchId.value = payload.payload.match_id || null;
        triggerLocalCountdown();
      }
    })
    .on('broadcast', { event: 'progress' }, (payload: any) => {
      opponentProgress.value = payload.payload.progress;
    })
    .on('broadcast', { event: 'opponent_finished' }, (payload: any) => {
      if (iFinishedFirst.value) return;
      opponentAdjustedTime.value = payload.payload.adjusted_time;
      if (!playerStats.value) {
        gracePeriodLeft.value = 10;
        gracePeriodTimer = setInterval(() => {
          gracePeriodLeft.value--;
          if (gracePeriodLeft.value <= 0) {
            clearGracePeriod();
            applyEloAndShowResult(false);
          }
        }, 1000);
      }
    })
    .on('broadcast', { event: 'grace_result' }, (payload: any) => {
      if (iFinishedFirst.value && playerStats.value) {
        clearGracePeriod();
        opponentAdjustedTime.value = payload.payload.adjusted_time;
        const iWon = playerStats.value.adjustedTime <= payload.payload.adjusted_time;
        applyEloAndShowResult(iWon);
      }
    })
    .on('broadcast', { event: 'disconnect' }, () => {
      opponentDisconnected.value = true;
      clearGracePeriod();
      if (view.value === 'arena') applyEloAndShowResult(true);
    })
    .on('broadcast', { event: 'easteregg_win' }, () => {
      clearGracePeriod();
      applyEloAndShowResult(false);
    })
    .subscribe(async (status: string) => {
      if (status === 'SUBSCRIBED') {
        await gameChannel.track({ username: localUser.name });
      }
    });
};


const clearGracePeriod = () => {
  if (gracePeriodTimer) { clearInterval(gracePeriodTimer); gracePeriodTimer = null; }
};

const applyEloAndShowResult = async (win: boolean) => {
  if (view.value === 'results') return;
  isSearching.value = false;
  didWin.value = win;
  const eloChange = win ? 25 : -15;
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');

  await supabase.from('users')
    .update({ elo: playerElo.value + eloChange }).eq('username', localUser.name);
  playerElo.value += eloChange;

  if (currentMatchId.value && currentUserId.value) {
    await supabase.from('matches').upsert(
      { matchid: currentMatchId.value, fk_leagueid: getLeagueId(playerElo.value - eloChange) },
      { onConflict: 'matchid' }
    );
    await supabase.from('plays').insert({
      fk_userid: currentUserId.value,
      fk_matchid: currentMatchId.value,
      opponent_username: opponentName.value,
      elo_change: eloChange,
      real_time_seconds: playerStats.value?.realTime ?? null,
      mistakes:          playerStats.value?.mistakes ?? null,
      adjusted_time:     playerStats.value?.adjustedTime ?? null,
      wpm:               playerStats.value?.wpm ?? null,
    });
    if (win) {
      await supabase.from('matches')
        .update({ winner_id: currentUserId.value }).eq('matchid', currentMatchId.value);
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

  if (opponentAdjustedTime.value !== null) {
    clearGracePeriod();
    const iWon = stats.adjustedTime < opponentAdjustedTime.value;
    if (gameChannel) {
      gameChannel.send({
        type: 'broadcast', event: 'grace_result',
        payload: { adjusted_time: stats.adjustedTime },
      });
    }
    await applyEloAndShowResult(iWon);
  } else {
    iFinishedFirst.value = true;
    if (gameChannel) {
      gameChannel.send({
        type: 'broadcast', event: 'opponent_finished',
        payload: { adjusted_time: stats.adjustedTime },
      });
    }
    gracePeriodLeft.value = 10;
    gracePeriodTimer = setInterval(() => {
      gracePeriodLeft.value--;
      if (gracePeriodLeft.value <= 0) {
        clearGracePeriod();
        applyEloAndShowResult(true);
      }
    }, 1000);
  }
};

const backToLobby = async () => {
  view.value = 'lobby';
  await loadUserData();
  await loadLastGames();
};

const onEasterEggWin = () => {
  clearGracePeriod();
  if (gameChannel) {
    gameChannel.send({ type: 'broadcast', event: 'easteregg_win', payload: {} });
  }
  applyEloAndShowResult(true);
};

const handleBeforeUnload = () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  if (!localUser.name) return;

  if (isSearching.value && view.value === 'lobby') {
    fetch(`${supabaseUrl}/rest/v1/matchmaking_queue?username=eq.${encodeURIComponent(localUser.name)}`, {
      method: 'DELETE',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Prefer': 'return=minimal',
      },
      keepalive: true,
    });
  }

  if (view.value === 'arena') {
    if (gameChannel) {
      gameChannel.send({ type: 'broadcast', event: 'disconnect', payload: {} });
    }
    fetch(`${supabaseUrl}/rest/v1/users?username=eq.${encodeURIComponent(localUser.name)}`, {
      method: 'PATCH',
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: JSON.stringify({ elo: playerElo.value - 15 }),
      keepalive: true,
    });
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
  clearGracePeriod();
  if (queueSub) queueSub.unsubscribe();
  if (gameChannel) gameChannel.unsubscribe();
});
</script>

<template>
  <div class="app-container">

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

    <div v-if="view === 'arena'" class="arena-container">

      <div v-if="!countdownStarted" class="countdown-overlay">
        <div class="connecting-spinner"></div>
        <div class="countdown-number" style="font-size:3rem; margin-top:16px">Connecting...</div>
        <div class="countdown-label">Waiting for both players</div>
      </div>

      <div v-else-if="countdown !== null" class="countdown-overlay">
        <div class="countdown-number">{{ countdown }}</div>
        <div class="countdown-label">GET READY</div>
      </div>

      <div v-else-if="iFinishedFirst && gracePeriodLeft > 0" class="countdown-overlay grace-overlay">
        <div class="countdown-number">{{ gracePeriodLeft }}</div>
        <div class="countdown-label">OPPONENT STILL TYPING — WAITING FOR ADJUSTED TIME</div>
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

      <div v-if="gracePeriodLeft > 0 && !iFinishedFirst" class="grace-bar">
        <span class="grace-label">⚡ Opponent finished! Beat their adjusted time — {{ gracePeriodLeft }}s left</span>
        <div class="grace-bg"><div class="grace-fill" :style="{ width: (gracePeriodLeft / 10 * 100) + '%' }"></div></div>
      </div>

      <Gameboard
        v-if="countdown === null && !iFinishedFirst"
        :key="gameText"
        :gametext="gameText"
        @progress="handleProgress"
        @finished="onFinished"
        @easteregg="onEasterEggWin"
      />
    </div>

    <div v-if="view === 'results'" class="results-screen">
      <div class="result-card">
        <template v-if="opponentDisconnected">
          <h1 class="win-text">VICTORY</h1>
          <p class="disconnect-msg">{{ opponentName }} has disconnected.</p>
        </template>
        <template v-else>
          <h1 :class="didWin ? 'win-text' : 'lose-text'">
            {{ didWin ? 'VICTORY' : 'DEFEAT' }}
          </h1>
        </template>

        <template v-if="playerStats">
          <p>Time: {{ playerStats.realTime.toFixed(2) }}s</p>
          <p v-if="playerStats.mistakes > 0" class="penalty-text">
            +{{ playerStats.mistakes * 3 }}s penalty ({{ playerStats.mistakes }} mistake{{ playerStats.mistakes > 1 ? 's' : '' }})
          </p>
          <p>Adjusted: <strong>{{ playerStats.adjustedTime.toFixed(2) }}s</strong></p>
          <p v-if="opponentAdjustedTime !== null" class="opponent-time">
            {{ opponentName }}: {{ opponentAdjustedTime?.toFixed(2) }}s adjusted
          </p>
        </template>

        <p class="elo-res">New Rating: {{ playerElo }}</p>
        <button class="ready-btn" @click="backToLobby">BACK TO LOBBY</button>
      </div>
    </div>

  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&display=swap');

.app-container { min-height: 100vh; width: 100vw; background-color: #0b0e14; overflow: hidden; display: flex; flex-direction: column; }
.league-page { font-family: 'Nunito', sans-serif; flex: 1; display: flex; color: #f8fafc; padding: 40px 60px; }
.side-panel { width: 280px; }
.stats-card { background: #1e293b; border-radius: 12px; border: 1px solid rgba(255,255,255,0.05); }
.elo-section { padding: 20px; }
.elo-label { display: block; font-size: 0.65rem; color: #64748b; font-weight: 800; letter-spacing: 1px; }
.elo-value { font-size: 2.2rem; font-weight: 900; color: #ff7e00; }
.recent-matches { padding: 0 15px 15px; }
.matches-title { font-size: 0.6rem; color: #475569; margin-bottom: 10px; font-weight: 900; }
.match-entry { background: rgba(11,14,20,0.3); margin-bottom: 5px; padding: 8px 12px; border-radius: 6px; display: flex; justify-content: space-between; }
.no-games { color: #475569; font-size: 0.75rem; padding: 8px 0; }
.plus { color: #10b981; }
.minus { color: #ef4444; }
.main-content { flex-grow: 1; padding-left: 50px; }
.league-title { color: #ff7e00; font-size: 3.5rem; font-weight: 900; }
.divider-main { height: 4px; background: #ff7e00; border-radius: 4px; margin: 5px 0 25px; }
.matchmaking-card { background: #1e293b; border-radius: 12px; padding: 25px 40px; display: flex; align-items: center; justify-content: space-between; }
.ready-btn { background: #ff7e00; border: none; color: #0b0e14; padding: 14px 30px; font-size: 1.2rem; font-weight: 900; border-radius: 8px; cursor: pointer; transition: 0.2s; }
.is-searching { background: #cc6600; animation: pulse 1.5s infinite; }

.arena-container { flex: 1; display: flex; flex-direction: column; align-items: center; padding: 40px; position: relative; }
.race-track { width: 100%; max-width: 800px; margin-bottom: 20px; }
.lane { margin-bottom: 20px; }
.lane-label { font-size: 0.8rem; font-weight: 800; color: #64748b; margin-bottom: 5px; }
.bar-bg { background: #1e293b; height: 12px; border-radius: 6px; overflow: hidden; }
.bar-fill { height: 100%; background: #ff7e00; transition: width 0.1s linear; }
.opponent-bar { background: #64748b; }

.countdown-overlay {
  position: absolute; inset: 0; background: rgba(11,14,20,0.92);
  display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 10;
}
.connecting-spinner {
  width: 56px; height: 56px;
  border: 5px solid rgba(255,126,0,0.2);
  border-top-color: #ff7e00;
  border-radius: 50%;
  animation: spin 0.9s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.grace-overlay { background: rgba(11,14,20,0.80); }
.countdown-number { font-family: 'Nunito',sans-serif; font-size: 9rem; font-weight: 900; color: #ff7e00; line-height: 1; animation: pop 0.9s ease-out infinite; }
.countdown-label { font-family: 'Nunito',sans-serif; font-size: 0.85rem; font-weight: 800; color: #64748b; letter-spacing: 3px; margin-top: 16px; text-align: center; max-width: 400px; }

.grace-bar { width: 100%; max-width: 800px; margin-bottom: 16px; }
.grace-label { font-size: 0.75rem; font-weight: 800; color: #f59e0b; margin-bottom: 6px; display: block; }
.grace-bg { background: #1e293b; height: 8px; border-radius: 4px; overflow: hidden; }
.grace-fill { height: 100%; background: #f59e0b; transition: width 1s linear; }

.results-screen { flex: 1; display: flex; justify-content: center; align-items: center; }
.result-card { background: #1e293b; padding: 50px; border-radius: 20px; text-align: center; border: 1px solid #ff7e00; }
.win-text { color: #10b981; font-size: 3rem; margin: 0 0 16px; }
.lose-text { color: #ef4444; font-size: 3rem; margin: 0 0 16px; }
.elo-res { color: #ff7e00; font-weight: 900; margin: 10px 0 25px; }
.penalty-text { color: #ef4444; font-size: 0.85rem; margin: 2px 0; }
.opponent-time { color: #64748b; font-size: 0.85rem; margin: 4px 0; }
.disconnect-msg { color: #94a3b8; font-size: 0.9rem; margin-bottom: 16px; }

@keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }
@keyframes pop { 0% { transform: scale(1.15); opacity: 0.6; } 100% { transform: scale(1); opacity: 1; } }
</style>

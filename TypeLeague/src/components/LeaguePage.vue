<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { supabase } from "../supabase";
import Gameboard from "./gameboard.vue";

const view = ref('lobby');
const playerElo = ref(1000);
const isSearching = ref(false);
const gameText = ref("The phantom typed blacked out like a ghost in the dark night.");

const opponentName = ref("Gegner");
const playerProgress = ref(0);
const opponentProgress = ref(0);
const playerStats = ref<any>(null);
const roomId = ref("");

const lastGames = ref([
  { opponent: 'TypeMaster99', change: '+24', win: true },
  { opponent: 'SpeedyGonzales', change: '-18', win: false }
]);

let queueSub: any = null;
let gameChannel: any = null;

const loadUserData = async () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  if (localUser.name) {
    const { data } = await supabase.from('users').select('elo').eq('username', localUser.name).single();
    if (data) playerElo.value = data.elo;
  }
};

onMounted(loadUserData);

const toggleReady = async () => {
  if (isSearching.value) {
    cancelSearch();
    return;
  }

  isSearching.value = true;
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');

  const { data: opponent } = await supabase
      .from('matchmaking_queue')
      .select('*')
      .eq('status', 'waiting')
      .neq('username', localUser.name)
      .limit(1)
      .maybeSingle();

  if (opponent) {
    const generatedId = "room_" + Math.random().toString(36).substr(2, 9);
    roomId.value = generatedId;
    opponentName.value = opponent.username;

    await supabase.from('matchmaking_queue')
        .update({ status: 'matched', room_id: generatedId })
        .eq('id', opponent.id);

    startMatch(generatedId);
  } else {
    const { data: myRequest } = await supabase.from('matchmaking_queue')
        .insert({ username: localUser.name, elo: playerElo.value, status: 'waiting' })
        .select().single();

    if (myRequest) {
      queueSub = supabase.channel('queue')
          .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'matchmaking_queue', filter: `id=eq.${myRequest.id}` },
              (payload) => {
                if (payload.new.status === 'matched') {
                  roomId.value = payload.new.room_id;
                  startMatch(payload.new.room_id);
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

const startMatch = (id: string) => {
  view.value = 'arena';
  playerProgress.value = 0;
  opponentProgress.value = 0;

  gameChannel = supabase.channel(id);
  gameChannel
      .on('broadcast', { event: 'progress' }, (payload: any) => {
        opponentProgress.value = payload.payload.progress;
      })
      .subscribe();
};

const handleProgress = (index: number) => {
  const progress = (index / gameText.value.length) * 100;
  playerProgress.value = progress;
  if (gameChannel) {
    gameChannel.send({
      type: 'broadcast',
      event: 'progress',
      payload: { progress }
    });
  }
};

const onFinished = async (stats: any) => {
  playerStats.value = stats;
  isSearching.value = false;

  const win = playerProgress.value >= 100 && opponentProgress.value < 100;
  const eloChange = win ? 25 : -15;

  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  await supabase.from('users').update({ elo: playerElo.value + eloChange }).eq('username', localUser.name);
  playerElo.value += eloChange;

  view.value = 'results';
};

onUnmounted(() => {
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
            <span class="elo-label">RANKED RATING</span>
            <div class="elo-display">
              <span class="elo-value">{{ playerElo }}</span>
            </div>
          </div>
          <div class="recent-matches">
            <h4 class="matches-title">LETZTE SPIELE</h4>
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
      <Gameboard :key="gameText" :gametext="gameText" @progress="handleProgress" @finished="onFinished" />
    </div>

    <div v-if="view === 'results'" class="results-screen">
      <div class="result-card">
        <h1 :class="playerProgress >= 100 ? 'win-text' : 'lose-text'">{{ playerProgress >= 100 ? 'VICTORY' : 'DEFEAT' }}</h1>
        <p>Time: {{ playerStats?.adjustedTime.toFixed(2) }}s</p>
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
.arena-container { flex: 1; display: flex; flex-direction: column; align-items: center; padding: 40px; }
.race-track { width: 100%; max-width: 800px; margin-bottom: 40px; }
.lane { margin-bottom: 20px; }
.lane-label { font-size: 0.8rem; font-weight: 800; color: #64748b; margin-bottom: 5px; }
.bar-bg { background: #1e293b; height: 12px; border-radius: 6px; overflow: hidden; }
.bar-fill { height: 100%; background: #ff7e00; transition: width 0.1s linear; }
.opponent-bar { background: #64748b; }
.results-screen { flex: 1; display: flex; justify-content: center; align-items: center; }
.result-card { background: #1e293b; padding: 50px; border-radius: 20px; text-align: center; border: 1px solid #ff7e00; }
.win-text { color: #10b981; font-size: 3rem; }
.lose-text { color: #ef4444; font-size: 3rem; }
.elo-res { color: #ff7e00; font-weight: 900; margin: 10px 0 25px; }
@keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }
</style>
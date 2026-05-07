<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import Gameboard from "./gameboard.vue";

const view = ref('selection');
const selectedBotWpm = ref(0);
const customWpmInput = ref(40);
const gameText = ref("");

const botProgress = ref(0);
const playerProgress = ref(0);
const botFinishedTime = ref(0);
const playerStats = ref<any>(null);
const isGameActive = ref(false);

const texts = [
  "The quick brown fox jumps over the lazy dog.",
  "Precision is just as important as speed when it comes to professional typing.",
  "TypeLeague is the ultimate platform to challenge your skills.",
  "A phantom typed blacked out like a ghost in the dark night."
];

const bots = [
  { name: 'Easy Bot', wpm: 30 },
  { name: 'Medium Bot', wpm: 60 },
  { name: 'Hard Bot', wpm: 100 }
];

onMounted(() => { document.body.style.overflow = 'hidden'; });
onUnmounted(() => { document.body.style.overflow = 'auto'; });

const setupMatch = (wpm: number) => {
  selectedBotWpm.value = wpm;
  gameText.value = texts[Math.floor(Math.random() * texts.length)];
  botProgress.value = 0;
  playerProgress.value = 0;
  botFinishedTime.value = (gameText.value.length / ((wpm * 5) / 60));
  playerStats.value = null;
  view.value = 'arena';
  isGameActive.value = false;
};

const handleStart = () => {
  isGameActive.value = true;
  simulateBot();
};

const simulateBot = () => {
  const totalDuration = botFinishedTime.value;
  let elapsed = 0;
  const step = 0.05;

  const interval = setInterval(() => {
    if (!isGameActive.value || view.value !== 'arena') {
      clearInterval(interval);
      return;
    }
    elapsed += step;
    botProgress.value = Math.min((elapsed / totalDuration) * 100, 100);
    if (botProgress.value >= 100) {
      clearInterval(interval);
      finishMatch();
    }
  }, step * 1000);
};

const onPlayerFinished = (stats: any) => {
  playerStats.value = stats;
  finishMatch();
};

const finishMatch = () => {
  isGameActive.value = false;
  view.value = 'results';
};

const winner = computed(() => {
  if (!playerStats.value) return 'Bot';
  return playerStats.value.adjustedTime < botFinishedTime.value ? 'Player' : 'Bot';
});
</script>

<template>
  <div class="training-wrapper">
    <div v-if="view === 'selection'" class="menu-card">
      <h1>Bot Training</h1>
      <div class="bot-grid">
        <button v-for="bot in bots" :key="bot.name" @click="setupMatch(bot.wpm)" class="bot-card">
          <span>{{ bot.name }}</span>
          <span class="bot-wpm">{{ bot.wpm }} WPM</span>
        </button>
      </div>
      <div class="custom-bot">
        <input type="number" v-model="customWpmInput" placeholder="WPM">
        <button @click="setupMatch(customWpmInput)">Start</button>
      </div>
    </div>

    <div v-if="view === 'arena'" class="arena">
      <div class="race-track">
        <div class="lane">
          <div class="lane-info">YOU</div>
          <div class="bar-bg">
            <div class="bar-fill player-fill" :style="{ width: playerProgress + '%' }"></div>
          </div>
        </div>
        <div class="lane">
          <div class="lane-info">BOT ({{ selectedBotWpm }} WPM)</div>
          <div class="bar-bg">
            <div class="bar-fill bot-fill" :style="{ width: botProgress + '%' }"></div>
          </div>
        </div>
      </div>
      <gameboard
          :key="gameText"
          :gametext="gameText"
          @start="handleStart"
          @finished="onPlayerFinished"
          @progress="(idx) => playerProgress = (idx / gameText.length) * 100"
      />
    </div>

    <div v-if="view === 'results'" class="menu-card results">
      <h1 :class="winner === 'Player' ? 'win' : 'lose'">
        {{ winner === 'Player' ? 'VICTORY' : 'DEFEAT' }}
      </h1>
      <div class="stats-summary">
        <p>Your Time: <span>{{ playerStats ? playerStats.adjustedTime.toFixed(2) : 'DNF' }}s</span></p>
        <p>Bot Time: <span>{{ botFinishedTime.toFixed(2) }}s</span></p>
        <p class="penalty-info" v-if="playerStats">Mistakes: {{ playerStats.mistakes }} (+{{ playerStats.mistakes * 3 }}s Penalty)</p>
      </div>
      <button class="mode-btn" @click="view = 'selection'">New Race</button>
    </div>
  </div>
</template>

<style scoped>
.training-wrapper { min-height: 100vh; background: #05080D; display: flex; justify-content: center; align-items: center; color: white; font-family: 'Nunito', sans-serif; }
.menu-card { background: #0B1117; padding: 40px; border-radius: 20px; border: 1px solid #263640; text-align: center; width: 420px; }
h1 { color: #BF5B04; margin-bottom: 20px; font-weight: 900; font-size: 2.5rem; }
.bot-grid { display: grid; gap: 10px; margin-bottom: 20px; }
.bot-card { background: #1c2730; border: 1px solid #263640; padding: 15px; border-radius: 10px; color: white; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
.bot-wpm { color: #BF5B04; font-weight: 800; }
.custom-bot { display: flex; gap: 10px; margin-bottom: 20px; }
.custom-bot input { background: #121820; border: 1px solid #263640; color: white; padding: 10px; border-radius: 8px; flex: 1; }
.custom-bot button { background: #BF5B04; border: none; color: white; padding: 0 15px; border-radius: 8px; cursor: pointer; font-weight: 800; }
.arena { width: 100%; display: flex; flex-direction: column; align-items: center; }
.race-track { width: 100%; max-width: 850px; margin-bottom: 30px; }
.lane { margin-bottom: 12px; }
.lane-info { font-size: 0.75rem; font-weight: 800; color: #65768C; margin-bottom: 4px; }
.bar-bg { background: #1c2730; height: 10px; border-radius: 5px; overflow: hidden; }
.bar-fill { height: 100%; transition: width 0.1s linear; }
.player-fill { background: #BF5B04; box-shadow: 0 0 10px #BF5B04; }
.bot-fill { background: #65768C; }
.win { color: #42b883; }
.lose { color: #e74c3c; }
.stats-summary { margin: 25px 0; font-size: 1.1rem; color: #65768C; }
.stats-summary span { color: white; font-weight: 800; }
.penalty-info { font-size: 0.9rem; margin-top: 10px; opacity: 0.7; }
.mode-btn { background: #BF5B04; color: white; border: none; padding: 15px 30px; border-radius: 10px; cursor: pointer; font-weight: 800; margin-top: 20px; width: 100%; }
</style>
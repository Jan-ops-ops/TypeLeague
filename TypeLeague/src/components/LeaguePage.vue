<script setup lang="ts">
import { ref, computed } from "vue";
import Gameboard from "./gameboard.vue";

const view = ref('lobby');
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
  "TypeLeague is the ultimate platform to challenge your skills and climb the ranks.",
  "A phantom typed blacked out like a ghost in the cold dark night of the arena.",
  "Mastering the keyboard requires patience, practice and a lot of dedication.",
  "Type faster than your shadow and leave your opponent in the dust."
];

const bots = [
  { name: 'Easy Bot', wpm: 30 },
  { name: 'Medium Bot', wpm: 60 },
  { name: 'Hard Bot', wpm: 100 }
];

const selectBot = (wpm: number) => {
  selectedBotWpm.value = wpm;
  startMatch();
};

const startMatch = () => {
  const randomIndex = Math.floor(Math.random() * texts.length);
  gameText.value = texts[randomIndex];

  botProgress.value = 0;
  playerProgress.value = 0;
  botFinishedTime.value = 0;
  playerStats.value = null;

  view.value = 'arena';
  isGameActive.value = true;

  simulateBot();
};

const simulateBot = () => {
  const totalChars = gameText.value.length;
  const charsPerSecond = (selectedBotWpm.value * 5) / 60;
  const totalDuration = totalChars / charsPerSecond;

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
      botFinishedTime.value = totalDuration;
      clearInterval(interval);
      checkMatchEnd();
    }
  }, step * 1000);
};

const handlePlayerProgress = (index: number) => {
  if (gameText.value.length > 0) {
    playerProgress.value = (index / gameText.value.length) * 100;
  }
};

const onPlayerFinished = (stats: any) => {
  playerStats.value = stats;
  playerProgress.value = 100;
  checkMatchEnd();
};

const checkMatchEnd = () => {
  if (playerStats.value && botProgress.value >= 100) {
    isGameActive.value = false;
    setTimeout(() => {
      view.value = 'results';
    }, 500);
  }
};

const winner = computed(() => {
  if (!playerStats.value) return 'Bot';
  return playerStats.value.adjustedTime < botFinishedTime.value ? 'Player' : 'Bot';
});
</script>

<template>
  <div class="league-wrapper">

    <div v-if="view === 'lobby'" class="menu-card">
      <h1>League Mode</h1>
      <div class="mode-options">
        <button class="mode-btn online disabled">Online Play (Soon)</button>
        <button class="mode-btn bot" @click="view = 'bot_selection'">VS Bot Play</button>
      </div>
    </div>

    <div v-if="view === 'bot_selection'" class="menu-card">
      <h1>Difficulty</h1>
      <div class="bot-grid">
        <button v-for="bot in bots" :key="bot.name" @click="selectBot(bot.wpm)" class="bot-card">
          <span class="bot-name">{{ bot.name }}</span>
          <span class="bot-wpm">{{ bot.wpm }} WPM</span>
        </button>
      </div>
      <div class="custom-bot">
        <input type="number" v-model="customWpmInput">
        <button @click="selectBot(customWpmInput)">Start</button>
      </div>
      <button class="back-link" @click="view = 'lobby'">Back</button>
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
          v-if="gameText"
          :key="gameText"
          :gametext="gameText"
          @finished="onPlayerFinished"
          @progress="handlePlayerProgress"
      />
    </div>

    <div v-if="view === 'results'" class="menu-card results">
      <h1 :class="winner === 'Player' ? 'win' : 'lose'">
        {{ winner === 'Player' ? 'VICTORY!' : 'DEFEAT!' }}
      </h1>
      <div class="stats-summary">
        <p>Your Time: <span>{{ playerStats?.adjustedTime.toFixed(2) }}s</span></p>
        <p>Bot Time: <span>{{ botFinishedTime.toFixed(2) }}s</span></p>
      </div>
      <button class="mode-btn bot" @click="view = 'lobby'">Try Again</button>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;900&display=swap');
.league-wrapper { min-height: 100vh; background: #05080D; font-family: 'Nunito', sans-serif; display: flex; justify-content: center; align-items: center; color: white; }
.menu-card { background: #0B1117; padding: 40px; border-radius: 20px; border: 1px solid #263640; text-align: center; width: 420px; }
h1 { font-size: 2.5rem; font-weight: 900; margin-bottom: 20px; color: #BF5B04; }
.mode-options { display: flex; flex-direction: column; gap: 15px; }
.mode-btn { padding: 15px; font-size: 1.2rem; font-weight: 800; border-radius: 10px; border: none; cursor: pointer; transition: 0.2s; }
.mode-btn.bot { background: #BF5B04; color: white; }
.mode-btn.disabled { background: #1c2730; color: #4a5d75; cursor: not-allowed; }
.bot-grid { display: grid; grid-template-columns: 1fr; gap: 10px; margin-bottom: 20px; }
.bot-card { background: #1c2730; border: 1px solid #263640; padding: 15px; border-radius: 10px; color: white; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
.bot-wpm { color: #BF5B04; font-weight: 800; }
.custom-bot { margin-bottom: 20px; display: flex; gap: 10px; }
.custom-bot input { background: #121820; border: 1px solid #263640; color: white; padding: 10px; border-radius: 8px; flex: 1; }
.arena { display: flex; flex-direction: column; align-items: center; width: 100%; }
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
.back-link { margin-top: 15px; background: none; border: none; color: #65768C; cursor: pointer; text-decoration: underline; }
</style>
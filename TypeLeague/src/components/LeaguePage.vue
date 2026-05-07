<script setup lang="ts">
import { ref } from 'vue';

const playerElo = ref(1250);
const isSearching = ref(false);

const lastGames = ref([
  { opponent: 'TypeMaster99', change: '+24', win: true },
  { opponent: 'SpeedyGonzales', change: '-18', win: false },
  { opponent: 'KeyboardWarrior', change: '+21', win: true }
]);

function toggleReady() {
  isSearching.value = !isSearching.value;
}
</script>

<template>
  <div class="app-container">

    <div class="league-page">
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
              <span :class="['elo-change', game.win ? 'plus' : 'minus']">
                {{ game.change }}
              </span>
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
              <p class="box-text">
                Klicke auf Ready, um einen Gegner auf deinem Niveau zu finden.
              </p>
            </div>

            <button
                class="ready-btn"
                :class="{ 'is-searching': isSearching }"
                @click="toggleReady"
            >
              <span class="btn-text">{{ isSearching ? 'SEARCHING...' : 'READY!' }}</span>
            </button>
          </div>

          <p class="footer-description">
            Tritt gegen andere Legenden in Echtzeit an
          </p>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&display=swap');

/* GLOBALER SCROLL-LOCK */
:global(html, body) {
  margin: 0;
  padding: 0;
  overflow: hidden !important; /* Absoluter Scroll-Stopp */
  height: 100%;
  width: 100%;
  background-color: #0b0e14;
}

.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.league-page {
  font-family: 'Nunito', sans-serif;
  flex: 1; /* Nimmt den restlichen Platz unter der Nav ein */
  display: flex;
  color: #f8fafc;
  padding: 40px 60px;
  box-sizing: border-box;
}

/* SIDE PANEL */
.side-panel {
  width: 280px;
  min-width: 280px;
  flex-shrink: 0;
}

.stats-card {
  background: #1e293b;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  width: 80%;
}

.elo-section { padding: 20px; }
.elo-label { display: block; font-size: 0.65rem; color: #64748b; font-weight: 800; letter-spacing: 1px; }
.elo-value { font-size: 2.2rem; font-weight: 900; color: #ff7e00; }
.lp-unit { font-size: 1rem; font-weight: 800; color: #ff7e00; margin-left: 4px; }

.recent-matches { padding: 0 15px 15px; }
.matches-title { font-size: 0.6rem; color: #475569; margin-bottom: 10px; font-weight: 900; padding-top: 12px; }
.match-entry { background: rgba(11, 14, 20, 0.3); margin-bottom: 5px; padding: 8px 12px; border-radius: 6px; display: flex;  justify-content: space-between; align-items: center; }
.opponent-name { font-size: 0.85rem; font-weight: 700; color: #cbd5e1; }
.elo-change { font-weight: 900; font-size: 0.85rem; margin-left: 8px; }
.plus { color: #10b981; }
.minus { color: #ef4444; }

/* MAIN CONTENT */
.main-content {
  flex-grow: 1;
  padding-left: 50px;
}

.league-title {
  color: #ff7e00;
  font-size: 3.5rem;
  font-weight: 900;
  margin: 0;
}

.divider-main {
  height: 4px;
  background: #ff7e00;
  border-radius: 4px;
  width: 100%;
  margin: 5px 0 25px 0;
}

/* MATCHMAKING BOX */
.matchmaking-card {
  background: #1e293b;
  border-radius: 12px;
  padding: 25px 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 30px;
  margin-bottom: 15px;
}

.box-title { font-size: 1.5rem; font-weight: 900; margin-bottom: 5px; }
.box-text { color: #94a3b8; font-size: 0.9rem; margin: 0; }

/* LEBENDIGER BUTTON */
.ready-btn {
  position: relative;
  background: #ff7e00;
  border: none;
  color: #0b0e14;
  width: 190px;
  padding: 14px 0;
  font-size: 1.4rem;
  font-weight: 900;
  border-radius: 8px;
  cursor: pointer;
  flex-shrink: 0;
  transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(255, 126, 0, 0.3);
}

.ready-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 0 25px rgba(255, 126, 0, 0.5);
  background: #ff8c1a;
}

.ready-btn:active {
  transform: scale(0.96);
}

.ready-btn.is-searching {
  background: #cc6600;
  box-shadow: inset 0 2px 8px rgba(0,0,0,0.3);
}

.footer-description { color: #475569; font-size: 1rem; font-weight: 600; }
</style>
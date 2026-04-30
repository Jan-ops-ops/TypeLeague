<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
const router = useRouter();

const levels = ref([
  { id: 1, title: 'Home Row Basics', desc: 'Die mittlere Reihe.', status: 'current' },
  { id: 2, title: 'Top Row Reach', desc: 'Obere Reihe.', status: 'locked' },
  { id: 3, title: 'Bottom Row Jump', desc: 'Untere Reihe.', status: 'locked' },
  { id: 4, title: 'Shift & Caps', desc: 'Großschreibung.', status: 'locked' },
  { id: 5, title: '50 WPM Barrier', desc: 'Speed Training.', status: 'locked' },
  { id: 6, title: 'Numbers', desc: 'Zahlen & Symbole.', status: 'locked' },
  { id: 7, title: 'Long Distance', desc: 'Ausdauer.', status: 'locked' },
  { id: 8, title: 'Elite', desc: 'Präzision.', status: 'locked' },
  { id: 9, title: 'League Ready', desc: 'Wettkampf.', status: 'locked' },
  { id: 10, title: 'Grandmaster', desc: '100+ WPM.', status: 'locked' }
]);

function gotolevel(event: MouseEvent, level: any) {
  if (level.status === 'locked') {
    const el = event.currentTarget as HTMLElement;
    el.classList.add('shake-it');
    setTimeout(() => el.classList.remove('shake-it'), 400);
    return;
  }
  router.push(`/Roadmaptyping/${level.id}`);
}
</script>

<template>
  <div class="roadmap-container">
    <h2 class="title">Skill Roadmap</h2>
    <p class="subtitle">Meistere den Pfad zur Legende</p>

    <div class="vertical-path">
      <div
          v-for="(level, index) in levels"
          :key="level.id"
          class="level-step"
          :class="[index % 2 === 0 ? 'left' : 'right', level.status]"
          @click="gotolevel($event, level)"
      >
        <div class="level-card">
          <div class="level-number">{{ level.id }}</div>
          <div class="level-content">
            <h3>{{ level.title }}</h3>
            <p>{{ level.desc }}</p>
          </div>
          <div class="status-indicator">
            <span v-if="level.status === 'locked'">🔒</span>
            <span v-else-if="level.status === 'completed'">✓</span>
            <span v-else>●</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.roadmap-container {
  background-color: #0b0e14;
  min-height: 100vh;
  padding: 60px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #f8fafc;
}

.title { color: #ff7e00; font-size: 2.5rem; margin-bottom: 5px; }
.subtitle { color: #64748b; margin-bottom: 60px; }

.vertical-path {
  position: relative;
  width: 100%;
  max-width: 600px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}


.vertical-path::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 50%;
  width: 4px;
  background: linear-gradient(to bottom, #ff7e00, #1e293b);
  transform: translateX(-50%);
  z-index: 0;
}

.level-step {
  display: flex;
  width: 100%;
  z-index: 1;
  position: relative;
}


.level-step.left { justify-content: flex-start; }
.level-step.right { justify-content: flex-end; }

.level-card {
  background: #1e293b;
  border: 2px solid #334155;
  border-radius: 12px;
  padding: 15px 20px;
  width: 240px;
  display: flex;
  align-items: center;
  gap: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
}


.level-step.left .level-card::after { right: -40px; transform: translateX(50%); }
.level-step.right .level-card::after { left: -40px; transform: translateX(-50%); }


.level-step.current .level-card { border-color: #ff7e00; box-shadow: 0 0 15px rgba(255, 126, 0, 0.3); }
.level-step.current .level-card::after { background: #ff7e00; }
.level-step.locked { opacity: 0.6; filter: grayscale(0.5); cursor: not-allowed; }


.level-card:not(.locked):hover {
  transform: scale(1.05);
  border-color: #ff7e00;
}

.level-number {
  background: #0b0e14;
  color: #ff7e00;
  width: 35px;
  height: 35px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  border: 1px solid #ff7e00;
}

.level-content h3 { font-size: 1rem; margin: 0; }
.level-content p { font-size: 0.8rem; color: #94a3b8; margin: 2px 0 0; }


@keyframes shake {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-8px); }
  40% { transform: translateX(8px); }
}

.shake-it .level-card {
  animation: shake 0.4s ease-in-out;
  border-color: #ef4444;
}
</style>
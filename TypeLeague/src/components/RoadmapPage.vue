<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from "../supabase";

const router = useRouter();

const levels = ref<any[]>([]);
const isLoading = ref<boolean>(true);
const errorMessage = ref<string>('');

const levelMeta: Record<number, { title: string; desc: string }> = {
  1: { title: 'Home Row Basics', desc: 'Die mittlere Reihe.' },
  2: { title: 'Top Row Reach', desc: 'Obere Reihe.' },
  3: { title: 'Bottom Row Jump', desc: 'Untere Reihe.' },
  4: { title: 'Shift & Caps', desc: 'Großschreibung.' },
  5: { title: '50 WPM Barrier', desc: 'Speed Training.' },
  6: { title: 'Numbers', desc: 'Zahlen & Symbole.' },
  7: { title: 'Long Distance', desc: 'Ausdauer.' },
  8: { title: 'Elite', desc: 'Präzision.' },
  9: { title: 'League Ready', desc: 'Wettkampf.' },
  10: { title: 'Grandmaster', desc: '100+ WPM.' }
};

const loadRoadmapData = async () => {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    const { data: dbLevels } = await supabase
      .from('levels')
      .select('*')
      .order('levelid', { ascending: true });

    const levelRows = (dbLevels && dbLevels.length > 0)
      ? dbLevels
      : Object.keys(levelMeta).map(id => ({ levelid: Number(id) }));

    const localUser = JSON.parse(localStorage.getItem('user') || '{}');
    const completedLevelIds = new Set<number>();
    let maxCompletedId = 0;

    if (localUser.name) {
      const { data: userData } = await supabase
        .from('users')
        .select('userid')
        .eq('username', localUser.name)
        .single();

      if (userData?.userid) {
        const { data: userProgress } = await supabase
          .from('user_level')
          .select('fk_levelid, completed')
          .eq('fk_userid', userData.userid)
          .eq('completed', true);

        if (userProgress && userProgress.length > 0) {
          userProgress.forEach((row: any) => {
            completedLevelIds.add(row.fk_levelid);
            if (row.fk_levelid > maxCompletedId) {
              maxCompletedId = row.fk_levelid;
            }
          });
        }
      }
    }

    const currentLevelId = maxCompletedId + 1;

    levels.value = levelRows.map((lvl: any) => {
      const id = lvl.levelid;
      let status = 'locked';

      if (completedLevelIds.has(id)) {
        status = 'done';
      } else if (id === currentLevelId || (id === 1 && maxCompletedId === 0)) {
        status = 'current';
      }

      const meta = levelMeta[id] || { title: `Level ${id}`, desc: `Erreiche die Ziellinie von Level ${id}.` };

      return {
        id,
        title: meta.title,
        desc: meta.desc,
        status,
      };
    });

  } catch (error: any) {
    errorMessage.value = error.message || 'Unbekannter Datenbankfehler.';
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  await loadRoadmapData();
});

function gotolevel(event: MouseEvent, level: any) {
  if (level.status === 'locked') {
    const el = event.currentTarget as HTMLElement;
    el.classList.add('shake-it');
    setTimeout(() => el.classList.remove('shake-it'), 400);
    return;
  }
  router.push({
    path: '/Roadmaptyping',
    state: { id: level.id }
  });
}
</script>

<template>
  <div class="roadmap-container">
    <h2 class="title">Skill Roadmap</h2>
    <p class="subtitle">Meistere den Pfad zur Legende</p>

    <div v-if="isLoading" class="state-msg">Lade Roadmap-Daten aus Supabase...</div>
    <div v-else-if="errorMessage" class="state-msg error">{{ errorMessage }}</div>

    <div v-else class="vertical-path">
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
            <span v-else-if="level.status === 'done'">✓</span>
            <span v-else>●</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&display=swap');

.roadmap-container {
  font-family: 'Nunito', sans-serif;
  background-color: #0b0e14;
  min-height: 100vh;
  padding: 60px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #f8fafc;
}

.title {
  color: #ff7e00;
  font-size: 2.5rem;
  margin-bottom: 5px;
  font-weight: 800;
}

.subtitle {
  color: #64748b;
  margin-bottom: 60px;
  font-weight: 400;
}

.state-msg {
  color: #94a3b8;
  font-size: 1.2rem;
  margin-top: 40px;
}

.state-msg.error {
  color: #ef4444;
  border: 1px dashed #ef4444;
  padding: 15px;
  border-radius: 8px;
  background: rgba(239, 68, 68, 0.05);
}

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

.level-step.current .level-card { border-color: #ff7e00; box-shadow: 0 0 15px rgba(255, 126, 0, 0.3); }
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
  font-weight: 900;
  border: 1px solid #ff7e00;
}

.level-content h3 {
  font-size: 1rem;
  margin: 0;
  font-weight: 700;
}
.level-content p {
  font-size: 0.8rem;
  color: #94a3b8;
  margin: 2px 0 0;
  font-weight: 400;
}

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

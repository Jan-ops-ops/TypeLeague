<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from "../supabase";
import { useI18n } from 'vue-i18n';
import MobileBlock from "./MobileBlock.vue";

const router = useRouter();
const { t, locale } = useI18n();

const levels = ref<any[]>([]);
const isLoading = ref<boolean>(true);
const errorMessage = ref<string>('');

const levelMeta = computed<Record<number, { title: string; desc: string }>>(() => ({
  1: { title: t('roadmap.level1_title'), desc: t('roadmap.level1_desc') },
  2: { title: t('roadmap.level2_title'), desc: t('roadmap.level2_desc') },
  3: { title: t('roadmap.level3_title'), desc: t('roadmap.level3_desc') },
  4: { title: t('roadmap.level4_title'), desc: t('roadmap.level4_desc') },
  5: { title: t('roadmap.level5_title'), desc: t('roadmap.level5_desc') },
  6: { title: t('roadmap.level6_title'), desc: t('roadmap.level6_desc') },
  7: { title: t('roadmap.level7_title'), desc: t('roadmap.level7_desc') },
  8: { title: t('roadmap.level8_title'), desc: t('roadmap.level8_desc') },
  9: { title: t('roadmap.level9_title'), desc: t('roadmap.level9_desc') },
  10: { title: t('roadmap.level10_title'), desc: t('roadmap.level10_desc') }
}));

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
        : Object.keys(levelMeta.value).map(id => ({ levelid: Number(id) }));

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

      const meta = levelMeta.value[id] || {
        title: `${t('roadmap.level')} ${id}`,
        desc: t('roadmap.default_level_desc')
      };

      return {
        id,
        title: meta.title,
        desc: meta.desc,
        status,
      };
    });

  } catch (error: any) {
    errorMessage.value = error.message || t('roadmap.error_db');
  } finally {
    isLoading.value = false;
  }
};

watch(locale, async () => {
  await loadRoadmapData();
});

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
  <MobileBlock />
  <div class="roadmap-container">
    <h2 class="title">{{ t('roadmap.title') }}</h2>
    <p class="subtitle">{{ t('roadmap.subtitle') }}</p>

    <div v-if="isLoading" class="state-msg">{{ t('roadmap.loading') }}</div>
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
  min-height: 80px;
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
  flex-shrink: 0;
}

.level-content {
  flex-grow: 1;
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

.status-indicator {
  flex-shrink: 0;
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

@media (max-width: 768px) {
  .roadmap-container { padding: 30px 16px; }
  .title { font-size: 1.8rem; }
  .vertical-path::before { left: 20px; }
  .level-step.left,
  .level-step.right { justify-content: flex-end; }
  .level-card { width: calc(100% - 44px); }
}
</style>
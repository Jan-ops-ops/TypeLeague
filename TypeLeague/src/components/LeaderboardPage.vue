<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '../supabase';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

interface Player {
  rank: number;
  username: string;
  elo: number;
  leagueKey: string;
}

const players = ref<Player[]>([]);
const isLoading = ref(true);
const currentUsername = ref('');

const getLeagueKey = (elo: number): string => {
  if (elo < 1200) return 'bronze';
  if (elo < 1400) return 'silver';
  if (elo < 1600) return 'gold';
  if (elo < 1800) return 'platinum';
  return 'diamond';
};

onMounted(async () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}');
  currentUsername.value = localUser.name || '';

  const { data } = await supabase
      .from('users')
      .select('username, elo')
      .order('elo', { ascending: false })
      .limit(100);

  if (data) {
    players.value = data.map((p, i) => ({
      rank: i + 1,
      username: p.username,
      elo: p.elo,
      leagueKey: getLeagueKey(p.elo),
    }));
  }

  isLoading.value = false;
});
</script>

<template>
  <div class="page">
    <h1 class="title">{{ t('leaderboard.title') }}</h1>
    <p class="subtitle">{{ t('leaderboard.subtitle') }}</p>

    <div v-if="isLoading" class="loading">{{ t('leaderboard.loading') }}</div>

    <div v-else class="board">

      <div class="table">
        <div class="table-header">
          <span class="col-rank">#</span>
          <span class="col-name">{{ t('leaderboard.th_player') }}</span>
          <span class="col-league">{{ t('leaderboard.th_league') }}</span>
          <span class="col-elo">{{ t('leaderboard.th_elo') }}</span>
        </div>
        <div
            v-for="player in players"
            :key="player.rank"
            class="table-row"
            :class="{ 'is-me': player.username === currentUsername }"
        >
          <span class="col-rank">{{ player.rank }}</span>
          <span class="col-name">{{ player.username }}</span>
          <span class="col-league" :class="'league-' + player.leagueKey">
            {{ t(`leaderboard.leagues.${player.leagueKey}`) }}
          </span>
          <span class="col-elo">{{ player.elo }}</span>
        </div>
      </div>

    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&display=swap');

.page {
  font-family: 'Nunito', sans-serif;
  background: #0b0e14;
  min-height: 100vh;
  padding: 60px 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #f8fafc;
}

.title {
  font-size: 2.5rem;
  font-weight: 900;
  color: #ff7e00;
  margin-bottom: 4px;
}

.subtitle {
  color: #64748b;
  font-size: 0.95rem;
  margin-bottom: 50px;
}

.loading {
  color: #64748b;
  font-size: 1.1rem;
  margin-top: 60px;
}

.board {
  width: 100%;
  max-width: 700px;
}

.table {
  background: #1e293b;
  border-radius: 14px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.05);
}

.table-header {
  display: grid;
  grid-template-columns: 50px 1fr 120px 80px;
  padding: 12px 20px;
  background: #0b0e14;
  font-size: 0.65rem;
  font-weight: 900;
  color: #475569;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.table-row {
  display: grid;
  grid-template-columns: 50px 1fr 120px 80px;
  padding: 14px 20px;
  border-top: 1px solid rgba(255,255,255,0.04);
  transition: background 0.15s;
}

.table-row:hover { background: rgba(255,255,255,0.03); }

.table-row.is-me {
  background: rgba(255, 126, 0, 0.08);
  border-left: 3px solid #ff7e00;
}

.col-rank { color: #475569; font-weight: 700; font-size: 0.9rem; }
.col-name { font-weight: 700; font-size: 0.95rem; }
.col-elo { color: #ff7e00; font-weight: 800; font-size: 0.95rem; text-align: right; }

.col-league { font-size: 0.75rem; font-weight: 800; letter-spacing: 0.5px; }
.league-bronze   { color: #b45309; }
.league-silver   { color: #94a3b8; }
.league-gold     { color: #f59e0b; }
.league-platinum { color: #67e8f9; }
.league-diamond  { color: #a78bfa; }

@media (max-width: 768px) {
  .page { padding: 30px 16px; }
  .title { font-size: 1.8rem; }
  .table-header,
  .table-row { grid-template-columns: 36px 1fr 80px 56px; padding: 10px 12px; }
  .col-league { font-size: 0.7rem; }
}
</style>
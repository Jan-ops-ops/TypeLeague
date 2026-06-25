<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { supabase } from "../supabase";
import { Line } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  PointElement,
  CategoryScale
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, LineElement, LinearScale, PointElement, CategoryScale);

const router = useRouter();
const { t } = useI18n();
const username = ref('');
const currentElo = ref(0);
const statsSummary = ref<any>(null);
const gameHistory = ref<any[]>([]);

const loadUserStats = async () => {
  const userData = localStorage.getItem('user');
  if (!userData) {
    await router.push("/login");
    return;
  }

  const parsedUser = JSON.parse(userData);
  let userId = parsedUser.id;

  if (!userId && parsedUser.name) {
    const { data: found } = await supabase
        .from('users')
        .select('userid, username, elo')
        .eq('username', parsedUser.name)
        .single();
    if (found) {
      userId = found.userid;
      username.value = found.username;
      currentElo.value = Number(found.elo) || 0;
    }
  }

  if (!userId) {
    username.value = parsedUser.name || 'Spieler';
    return;
  }

  const { data: userDb, error: userError } = await supabase
      .from('users')
      .select('username, elo')
      .eq('userid', userId)
      .single();

  if (userError || !userDb) {
    username.value = parsedUser.name || 'Spieler';
  } else {
    username.value = userDb.username;
    currentElo.value = Number(userDb.elo) || 0;
  }

  const {data: plays, error: playsError} = await supabase
      .from('plays')
      .select('playid, real_time_seconds, mistakes, adjusted_time, wpm, elo_change, opponent_username, created_at')
      .eq('fk_userid', userId)
      .order('playid', {ascending: true});

  if (playsError) {
    console.error("Fehler beim Laden der Plays:", playsError);
    return;
  }

  if (plays && plays.length > 0) {
    const sanitizedPlays = plays.map(p => ({
      playid: p.playid,
      wpm: p.wpm !== null ? Number(p.wpm) : 0,
      mistakes: p.mistakes !== null ? Number(p.mistakes) : 0,
      real_time_seconds: p.real_time_seconds !== null ? Number(p.real_time_seconds) : 0,
      adjusted_time: p.adjusted_time !== null ? Number(p.adjusted_time) : 0,
      elo_change: p.elo_change !== null ? Number(p.elo_change) : 0,
      opponent: p.opponent_username || '??',
      created_at: p.created_at
    }));
    gameHistory.value = [...sanitizedPlays].reverse();

    const totalGames = sanitizedPlays.length;
    const maxWpm = Math.max(...sanitizedPlays.map(p => p.wpm));
    const totalMistakes = sanitizedPlays.reduce((sum, p) => sum + p.mistakes, 0);
    const avgWpm = sanitizedPlays.reduce((sum, p) => sum + p.wpm, 0) / totalGames;

    statsSummary.value = {
      totalGames,
      maxWpm,
      totalMistakes,
      avgWpm: avgWpm.toFixed(1),
      currentElo: currentElo.value
    };
  }
};

const chartFullDates = ref<string[]>([]);

const chartData = computed(() => {
  if (gameHistory.value.length === 0) {
    chartFullDates.value = [];
    return { labels: ['Start'], datasets: [{ data: [currentElo.value] }] };
  }

  const chronological = [...gameHistory.value].reverse();

  const totalChange = chronological.reduce((sum, p) => sum + p.elo_change, 0);
  let runningElo = currentElo.value - totalChange;

  const eloPoints = [runningElo];
  const labels = ['Start'];
  const fullDates = ['Start-Rating'];

  chronological.forEach(p => {
    runningElo += p.elo_change;
    eloPoints.push(runningElo);

    const dateStr = p.created_at ? String(p.created_at).replace(' ', 'T') : '';
    const dateObj = new Date(dateStr);

    const isValid = !isNaN(dateObj.getTime());

    const formattedTime = isValid
        ? dateObj.toLocaleTimeString('ch-CH', { hour: '2-digit', minute: '2-digit' })
        : '??:??';
    labels.push(formattedTime);

    const formattedFull = isValid
        ? dateObj.toLocaleString('ch-CH', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
        : 'Unbekanntes Datum';
    fullDates.push(formattedFull);
  });

  chartFullDates.value = fullDates;

  return {
    labels: labels,
    datasets: [
      {
        label: 'Rating',
        backgroundColor: '#BF5B04',
        borderColor: '#BF5B04',
        pointBackgroundColor: '#BF5B04',
        tension: 0.2,
        data: eloPoints
      }
    ]
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      callbacks: {
        title: (context: any) => {
          const index = context[0].dataIndex;
          return chartFullDates.value[index] || '';
        }
      }
    }
  },
  scales: {
    y: { grid: { color: '#312e2b' }, ticks: { color: '#989795', font: { family: 'Nunito' } } },
    x: { grid: { display: false }, ticks: { color: '#989795', font: { family: 'Nunito' } } }
  }
};

onMounted(() => {
  loadUserStats();
});
</script>

<template>
  <div class="stats-container">
    <div class="user-header" v-if="username">
      <div class="avatar-placeholder">{{ username.substring(0, 2).toUpperCase() }}</div>
      <div class="user-info">
        <h1>{{ username }}</h1>
        <span class="user-badge">{{ t('stats.live_rating') }}: {{ currentElo }}</span>
      </div>
    </div>


    <div v-if="statsSummary" class="stats-grid">
      <div class="stat-card">
        <h3>{{ t('stats.games') }}</h3>
        <p class="stat-value">{{ statsSummary.totalGames }}</p>
      </div>
      <div class="stat-card">
        <h3>{{ t('stats.best_wpm') }}</h3>
        <p class="stat-value unique">{{ statsSummary.maxWpm }}</p>
      </div>
      <div class="stat-card">
        <h3>{{ t('stats.avg_wpm') }}</h3>
        <p class="stat-value">{{ statsSummary.avgWpm }}</p>
      </div>
      <div class="stat-card">
        <h3>{{ t('stats.mistakes') }}</h3>
        <p class="stat-value">{{ statsSummary.totalMistakes }}</p>
      </div>
      <div class="stat-cardHighlight">
        <h3>{{ t('stats.rating') }}</h3>
        <p class="stat-value elo">{{ statsSummary.currentElo }}</p>
      </div>
    </div>

    <div class="chart-section" v-if="gameHistory.length > 0">
      <h3>{{ t('stats.chart_title') }}</h3>
      <div class="chart-wrapper">
        <Line :data="chartData" :options="chartOptions" />
      </div>
    </div>

    <div class="history-section">
      <h3>{{ t('stats.history_title') }}</h3>
      <table v-if="gameHistory && gameHistory.length > 0">
        <thead>
        <tr>
          <th>{{ t('stats.th_player') }}</th>
          <th>{{ t('stats.th_result') }}</th>
          <th>{{ t('stats.th_wpm') }}</th>
          <th>{{ t('stats.th_mistakes') }}</th>
          <th>{{ t('stats.th_time') }}</th>
          <th>{{ t('stats.th_elo') }}</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(play, index) in gameHistory" :key="index">
          <td>
            <div class="versus-cell">
              <span class="my-name">{{ username }}</span>
              <span class="vs">vs</span>
              <span class="opponent-name">{{ play.opponent }}</span>
            </div>
          </td>

          <td>
            <span :class="play.elo_change >= 0 ? 'badge-win' : 'badge-loss'">
              {{ play.elo_change >= 0 ? t('stats.win') : t('stats.loss') }}
            </span>
          </td>

          <td><strong>{{ play.wpm }}</strong></td>
          <td>{{ play.mistakes }}</td>
          <td>{{ play.real_time_seconds }}s</td>
          <td :class="play.elo_change >= 0 ? 'text-green' : 'text-red'">
            {{ play.elo_change >= 0 ? '+' : '' }}{{ play.elo_change }}
          </td>
        </tr>
        </tbody>
      </table>
      <p v-else class="empty-state">{{ t('stats.empty') }}</p>
    </div>
  </div>
</template>

<style scoped>
.stats-container {
  font-family: 'Nunito', sans-serif;
  max-width: 900px;
  margin: 40px auto;
  padding: 24px;
  background-color: #262522;
  color: #fff;
  border-radius: 8px;
}

.user-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #312e2b;
}

.avatar-placeholder {
  width: 70px;
  height: 70px;
  background: #312e2b;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.6rem;
  font-weight: 700;
  color: #BF5B04;
}

.user-info h1 {
  margin: 0;
  font-size: 2rem;
  font-weight: 700;
}

.user-badge {
  background: #312e2b;
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 0.8rem;
  color: #989795;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
  margin-bottom: 35px;
}

.stat-card, .stat-cardHighlight {
  background: #2d2b28;
  border-radius: 6px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.stat-cardHighlight {
  background: #312e2b;
  border: 1px solid #ffa726;
}

.stat-card h3, .stat-cardHighlight h3 {
  font-size: 0.85rem;
  color: #989795;
  margin: 0 0 6px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-value {
  font-size: 1.8rem;
  font-weight: 800;
  margin: 0;
}

.stat-value.unique { color: #81b64c; }
.stat-value.elo { color: #ffa726; }

.chart-section {
  margin-bottom: 35px;
  background: #2d2b28;
  padding: 20px;
  border-radius: 6px;
}

.chart-section h3, .history-section h3 {
  margin-top: 0;
  font-size: 1.2rem;
  color: #fff;
  margin-bottom: 15px;
}

.chart-wrapper {
  height: 250px;
  position: relative;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  color: #989795;
  font-weight: 600;
  font-size: 0.9rem;
  padding: 12px;
  text-align: center;
  border-bottom: 2px solid #312e2b;
}

td {
  padding: 14px 12px;
  text-align: center;
  border-bottom: 1px solid #312e2b;
  font-size: 0.95rem;
}

tr:hover {
  background-color: #2d2b28;
}

.match-number {
  color: #989795;
  font-weight: bold;
}

.text-green { color: #81b64c; font-weight: 700; }
.text-red { color: #fa4a4a; font-weight: 700; }
.empty-state { text-align: center; color: #989795; padding: 20px; }

.versus-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-weight: 600;
}

.vs {
  color: #989795;
  font-size: 0.8rem;
  font-weight: normal;
  text-transform: uppercase;
}

.opponent-name {
  color: #bab9b7;
}

.badge-win, .badge-loss {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: bold;
  text-transform: uppercase;
  display: inline-block;
  min-width: 75px;
}

.badge-win {
  background-color: #4e7828;
  color: #fff;
}

.badge-loss {
  background-color: #b23330;
  color: #fff;
}

@media (max-width: 768px) {
  .stats-container { margin: 16px; padding: 16px; }
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
  .history-section { overflow-x: auto; }
  table { min-width: 520px; }
  th, td { padding: 10px 8px; font-size: 0.82rem; }
  .chart-wrapper { height: 180px; }
  .user-info h1 { font-size: 1.4rem; }
}
</style>
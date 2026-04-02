<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter, useRoute } from 'vue-router';

const { locale, t } = useI18n();
const router = useRouter();
const route = useRoute();

const currentLanguage = ref(locale.value);
const dropdownOpen = ref(false);
const isLoggedIn = ref(false);

const checkAuth = () => {
  isLoggedIn.value = !!localStorage.getItem('user');
};

onMounted(checkAuth);

watch(() => route.path, checkAuth);

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
};

const switchLanguage = (lang: string) => {
  currentLanguage.value = lang;
  locale.value = lang;
  dropdownOpen.value = false;
};

const logout = () => {
  localStorage.removeItem('user');
  isLoggedIn.value = false;
  router.push('/login');
};
</script>

<template>
  <nav class="navbar">
    <div class="logo" @click="$router.push('/')">TypeLeague</div>

    <div class="nav-links">
      <router-link to="/roadmap" class="nav-link">{{ $t('navbar.roadmap')}}</router-link>
      <router-link to="/league" class="nav-link">{{ $t('navbar.league')}}</router-link>
      <router-link to="/training" class="nav-link">{{ $t('navbar.training')}}</router-link>
      <router-link to="/leaderboard" class="nav-link">{{ $t('navbar.leaderboard')}}</router-link>
      <router-link to="/stats" class="nav-link">{{ $t('navbar.stats')}}</router-link>
    </div>

    <div class="nav-right">
      <template v-if="!isLoggedIn">
        <router-link to="/login" class="btn-text">{{ $t('navbar.login') }}</router-link>
        <router-link to="/register" class="btn">{{ $t('navbar.register') }}</router-link>
      </template>

      <template v-else>
        <button @click="logout" class="btn-outline">{{ $t('navbar.logout') }}</button>
      </template>

      <div class="language-wrapper" @mouseleave="dropdownOpen=false">
        <button class="lang-btn" @click="toggleDropdown">
          {{ currentLanguage.toUpperCase() }}
          <span class="arrow" :class="{ open: dropdownOpen }">▼</span>
        </button>

        <div class="lang-dropdown" v-show="dropdownOpen">
          <div class="lang-item" @click="switchLanguage('en')">EN</div>
          <div class="lang-item" @click="switchLanguage('de')">DE</div>
          <div class="lang-item" @click="switchLanguage('fr')">FR</div>
        </div>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 40px;
  background: #05080D;
  font-family: 'Inter', sans-serif;
  border-bottom: 1px solid #263640;
}

.logo {
  font-size: 1.5rem;
  font-weight: 700;
  color: #BF5B04;
  cursor: pointer;
}

.nav-links {
  display: flex;
  gap: 25px;
}

.nav-link {
  color: #65768C;
  text-decoration: none;
  transition: 0.3s;
  font-weight: 500;
}

.nav-link:hover, .router-link-active {
  color: #BF5B04;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.btn-text {
  color: #65768C;
  text-decoration: none;
  transition: 0.3s;
}

.btn-text:hover { color: white; }

.btn {
  padding: 8px 18px;
  background: #BF5B04;
  color: white;
  border-radius: 6px;
  text-decoration: none;
  transition: 0.3s;
  border: none;
  cursor: pointer;
}

.btn:hover { background: #733917; }

.btn-outline {
  padding: 8px 18px;
  border: 1px solid #BF5B04;
  color: #BF5B04;
  background: transparent;
  border-radius: 6px;
  text-decoration: none;
  transition: 0.3s;
  cursor: pointer;
}

.btn-outline:hover {
  background: #BF5B04;
  color: white;
}

.language-wrapper { position: relative; }
.lang-btn {
  padding: 6px 12px;
  background: #263640;
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
}
.lang-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  background: #263640;
  border-radius: 8px;
  z-index: 100;
  margin-top: 0px;
  overflow: hidden;
}
.lang-item { padding: 8px 20px; cursor: pointer; color: white; }
.lang-item:hover { background: #BF5B04; }
</style>
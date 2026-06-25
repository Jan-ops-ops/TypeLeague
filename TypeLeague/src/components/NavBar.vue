<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter, useRoute } from 'vue-router';

const { locale, t } = useI18n();
const router = useRouter();
const route = useRoute();

const dropdownOpen = ref(false);
const menuOpen = ref(false);
const isLoggedIn = ref(false);

const checkAuth = () => {
  isLoggedIn.value = !!localStorage.getItem('user');
};

onMounted(() => {
  checkAuth();
  const savedLang = localStorage.getItem('user_lang');
  if (savedLang) {
    locale.value = savedLang;
  }
});

watch(() => route.path, () => {
  checkAuth();
  menuOpen.value = false;
});

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
};

const switchLanguage = (lang: string) => {
  locale.value = lang;
  localStorage.setItem('user_lang', lang);
  dropdownOpen.value = false;
};

const logout = () => {
  localStorage.removeItem('user');
  isLoggedIn.value = false;
  router.push('/');
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
          {{ locale.toUpperCase() }}
          <span class="arrow" :class="{ open: dropdownOpen }">▼</span>
        </button>
        <div class="lang-dropdown" v-show="dropdownOpen">
          <div class="lang-item" @click="switchLanguage('en')">EN</div>
          <div class="lang-item" @click="switchLanguage('de')">DE</div>
          <div class="lang-item" @click="switchLanguage('fr')">FR</div>
        </div>
      </div>

      <button class="hamburger" @click="menuOpen = !menuOpen">☰</button>
    </div>

    <div class="mobile-menu" v-show="menuOpen" @click="menuOpen = false">
      <router-link to="/roadmap" class="mobile-link">{{ $t('navbar.roadmap')}}</router-link>
      <router-link to="/league" class="mobile-link">{{ $t('navbar.league')}}</router-link>
      <router-link to="/training" class="mobile-link">{{ $t('navbar.training')}}</router-link>
      <router-link to="/leaderboard" class="mobile-link">{{ $t('navbar.leaderboard')}}</router-link>
      <router-link to="/stats" class="mobile-link">{{ $t('navbar.stats')}}</router-link>
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
  position: sticky;
  top: 0;
  z-index: 10000;
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
  overflow: hidden;
}
.lang-item { padding: 8px 20px; cursor: pointer; color: white; }
.lang-item:hover { background: #BF5B04; }

.hamburger {
  display: none;
  background: none;
  border: 1px solid #263640;
  color: white;
  padding: 6px 11px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1.1rem;
  line-height: 1;
}

.mobile-menu {
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #05080D;
  border-bottom: 1px solid #263640;
  flex-direction: column;
}

.mobile-link {
  padding: 14px 24px;
  color: #65768C;
  text-decoration: none;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  border-bottom: 1px solid #0d1520;
  transition: color 0.2s;
}

.mobile-link:hover, .mobile-link.router-link-active {
  color: #BF5B04;
}

@media (max-width: 768px) {
  .navbar { padding: 12px 16px; }
  .nav-links { display: none; }
  .hamburger { display: block; }
  .mobile-menu { display: flex; }
  .btn-text { display: none; }
  .btn { padding: 7px 12px; font-size: 0.85rem; }
  .btn-outline { padding: 7px 12px; font-size: 0.85rem; }
  .logo { font-size: 1.2rem; }
}
</style>

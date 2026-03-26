<script setup lang="ts">
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';

const { locale } = useI18n();

const currentLanguage = ref(locale.value);

const switchLanguage = () => {
  locale.value = currentLanguage.value;
};
</script>

<template>
  <nav class="navbar">
    <div class="nav-left">
      <h1>TypeLeague</h1>
        <nav class="nav-links">
          <router-link class="nav-link" to="/">Home</router-link>
          <router-link class="nav-link" to="/roadmap">{{ $t('navbar.roadmap')}}</router-link>
          <router-link class="nav-link" to="/league">{{ $t('navbar.league')}}</router-link>
          <router-link class="nav-link" to="/training">{{ $t('navbar.training')}}</router-link>
          <router-link class="nav-link" to="/leaderboard">{{ $t('navbar.leaderboard')}}</router-link>
          <router-link class="nav-link" to="/stats">{{ $t('navbar.stats')}}</router-link>

          <router-link class="nav-link" to="/register">{{ $t('navbar.register') }}</router-link>

          <router-link class="nav-link" to="/login">{{ $t('navbar.login') }}</router-link>

        </nav>
    </div>

    <div class="nav-right">
      <select v-model="currentLanguage" @change="switchLanguage">
        <option value="en">English</option>
        <option value="de">Deutsch</option>
        <option value="fr">Français</option>
      </select>
    </div>
  </nav>
</template>

<style scoped>

</style>
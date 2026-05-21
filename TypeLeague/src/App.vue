<script setup lang="ts">
import { RouterView } from 'vue-router'
import NavBar from "./components/NavBar.vue";
import { onMounted } from 'vue';
import { useI18n } from 'vue-i18n';

const { locale } = useI18n();

onMounted(() => {
  const userData = localStorage.getItem('user');
  if (userData) {
    const user = JSON.parse(userData);
    if (user.lang) {
      locale.value = user.lang; // Setzt die Sprache auf den gespeicherten Wert
    }
  }
});
</script>

<template>

  <NavBar/>
  <RouterView/>



</template>
<style scoped>

</style>
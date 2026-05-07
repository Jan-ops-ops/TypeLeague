roadmaptyping:
<script setup lang="ts">
import Gameboard from "./gameboard.vue";
import { useRouter } from 'vue-router';
import { onMounted, ref } from 'vue';
const router = useRouter();
// Wir nutzen ein Ref für die ID, da sie erst beim Mounten aus dem State gelesen wird
const levelId = ref<string | number | null>(null);
onMounted(() => {
  // Zugriff auf die ID, die du via router.push({ state: { id: ... } }) gesendet hast
  if (window.history.state && window.history.state.id) {
    levelId.value = window.history.state.id;
    console.log("Gewähltes Level aus State:", levelId.value);
  }
});
const levelfinished = false;
function iflevelfinished() {
  router.push('/roadmap');
}
</script>
<template>
  <gameboard
      gametext="AAAGOSFoHSOIHF"
  >
  </gameboard>
</template>
<style scoped>
</style>
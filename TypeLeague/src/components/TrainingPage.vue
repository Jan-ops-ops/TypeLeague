<script setup lang="ts">
import { onMounted, onUnmounted } from "vue";
import Gameboard from "./gameboard.vue";

onMounted(() => {
  document.body.style.overflow = 'hidden';
});

onUnmounted(() => {
  document.body.style.overflow = 'auto';
});
</script>

<template>
  <div class="training-wrapper">
    <gameboard
        gametext="AAAA AAAA aaa aaa aaa aaa"
    ></gameboard>
  </div>
</template>

<style scoped>
.training-wrapper {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background: #05080D;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
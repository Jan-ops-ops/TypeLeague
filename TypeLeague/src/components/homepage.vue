<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

const text = "TypeLeague";
const displayedText = ref("");
const isDeleting = ref(false);
let i = 0;

onMounted(() => {
  const typingSpeed = 150;
  const deletingSpeed = 100;
  const pauseTime = 3000;

  const loop = () => {
    if (!isDeleting.value) {
      displayedText.value = text.substring(0, i++);
      if (i > text.length) {
        isDeleting.value = true;
        setTimeout(loop, pauseTime);
        return;
      }
      setTimeout(loop, typingSpeed);
    } else {
      displayedText.value = text.substring(0, i--);
      if (i === 0) isDeleting.value = false;
      setTimeout(loop, deletingSpeed);
    }
  };

  loop();
});
</script>

<template>
  <div class="home-wrapper">
    <h1 class="title">{{ displayedText }}<span class="cursor">|</span></h1>

    <p class="description">{{ t('homepage.description') }}</p>
    <p class="why">{{ t('homepage.why') }}</p>
    <p class="competitive">{{ t('homepage.competitive') }}</p>

    <router-link class="cta-btn" to="/roadmap">{{ t('homepage.roadmapCTA') }}</router-link>
  </div>
</template>

<style scoped>

.home-wrapper {
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: radial-gradient(circle at center, #0b1117 0%, #05080D 100%);
  color: white;
  text-align: center;
  padding: 20px;
}

.title {
  font-family: 'Nunito', sans-serif;
  font-size: 5rem;
  font-weight: 700;
  color: #BF5B04;
  text-shadow: 0 0 20px rgba(191,91,4,0.4);
}

.cursor {
  margin-left: 5px;
  animation: blink 1s infinite;
}

.description, .why, .competitive {
  margin-top: 20px;
  font-family: 'Inter', sans-serif;
  font-size: 1.2rem;
  color: #65768C;
  max-width: 600px;
}

.cta-btn {
  margin-top: 40px;
  padding: 12px 28px;
  background: #BF5B04;
  color: white;
  font-family: 'Inter', sans-serif;
  font-weight: 600;
  border-radius: 8px;
  text-decoration: none;
  transition: all 0.3s ease;
}

.cta-btn:hover {
  background: #733917;
  transform: translateY(-2px);
}

@keyframes blink { 50% { opacity: 0; } }
</style>
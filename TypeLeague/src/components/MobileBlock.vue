<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const isMobile = ref(false);
const check = () => {
  isMobile.value = window.innerWidth <= 768;
  document.body.style.overflow = isMobile.value ? 'hidden' : '';
};
onMounted(() => { check(); window.addEventListener('resize', check); });
onUnmounted(() => { window.removeEventListener('resize', check); document.body.style.overflow = ''; });
</script>

<template>
  <div v-if="isMobile" class="mobile-overlay">
    <div class="mobile-card">
      <div class="keyboard-icon">⌨️</div>
      <h2>{{ t('mobile.title') }}</h2>
      <p>{{ t('mobile.message') }}</p>
    </div>
  </div>
</template>

<style scoped>
.mobile-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: #05080D;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  font-family: 'Nunito', sans-serif;
}

.mobile-card {
  background: #0B1117;
  border: 1px solid #263640;
  border-radius: 16px;
  padding: 40px 32px;
  text-align: center;
  max-width: 340px;
  color: white;
}

.keyboard-icon {
  font-size: 3rem;
  margin-bottom: 16px;
}

h2 {
  font-size: 1.5rem;
  font-weight: 800;
  color: #BF5B04;
  margin: 0 0 12px;
}

p {
  color: #65768C;
  font-size: 0.95rem;
  line-height: 1.6;
  margin: 0;
}
</style>

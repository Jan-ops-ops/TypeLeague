<script setup lang="ts">
import Gameboard from "./gameboard.vue";
import { useRouter } from 'vue-router';
import { onMounted, ref } from 'vue';
import { supabase } from "../supabase";

const router = useRouter();

const levelId = ref<number | null>(null);
const gametext = ref<string>("");
const isReady = ref(false);

onMounted(async () => {
  if (window.history.state && window.history.state.id) {
    levelId.value = Number(window.history.state.id);
    await fetchLevelText(levelId.value);
  }
  isReady.value = true;
});

async function fetchLevelText(id: number) {
  const { data, error } = await supabase
    .from('levels')
    .select('content')
    .eq('levelid', id)
    .single();

  if (!error && data?.content) {
    gametext.value = data.content;
  }
}

async function onLevelFinished() {
  try {
    const localUser = JSON.parse(localStorage.getItem('user') || '{}');

    if (localUser.name && levelId.value !== null) {
      const { data: userData } = await supabase
        .from('users')
        .select('userid')
        .eq('username', localUser.name)
        .single();

      if (userData?.userid) {
        const { data: existing } = await supabase
          .from('user_level')
          .select('fk_userid')
          .eq('fk_userid', userData.userid)
          .eq('fk_levelid', levelId.value)
          .maybeSingle();

        if (existing) {
          await supabase
            .from('user_level')
            .update({ completed: true })
            .eq('fk_userid', userData.userid)
            .eq('fk_levelid', levelId.value);
        } else {
          await supabase
            .from('user_level')
            .insert({ fk_userid: userData.userid, fk_levelid: levelId.value, completed: true });
        }
      }
    }
  } catch (err) {
    console.error(err);
  }

  router.push('/roadmap');
}
</script>

<template>
  <div class="roadmaptyping-container">
    <gameboard
      v-if="isReady && gametext"
      :gametext="gametext"
      @finished="onLevelFinished"
      @easteregg="onLevelFinished"
    />
  </div>
</template>

<style scoped>
.roadmaptyping-container {
  width: 100%;
  height: 100%;
}
</style>

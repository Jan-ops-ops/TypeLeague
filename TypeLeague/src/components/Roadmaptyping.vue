<script setup lang="ts">
import Gameboard from "./gameboard.vue";
import { useRouter } from 'vue-router';
const router = useRouter();
const levelId = router.params.id;
console.log("Gewähltes Level ist:", levelId);
const levelfinished = false
function iflevelfinished()
{
router.push('/roadmap')

}

</script>

<template>
<gameboard
gametext="AAAGOSFoHSOIHF"

>


</gameboard>
  <!-- if level = finished oder so-->
</template>

<style scoped>

</style>
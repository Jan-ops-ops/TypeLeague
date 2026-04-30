<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";

const props = defineProps<{
  gametext: string
}>();

const emit = defineEmits(['finished', 'start', 'progress']);

interface KeyboardKey {
  main: string;
  shift?: string;
  zone: string;
  code: string;
  isSpecial?: boolean;
  width?: string;
}

const currentIndex = ref(0);
const activeKeys = ref(new Set());
const lastWrongIndex = ref(-1);
const charWidth = 25;

const totalMistakes = ref(0);
const hasErrorAtPosition = ref(false);
const isFinished = ref(false);
const startTime = ref<number | null>(null);

const secretBuffer = ref("");
const showEasterEgg = ref(false);
const secretPhrase = "blacked out like a phantom";

const keyboardlayout: KeyboardKey[][] = [
  [
    { main: '§', shift: '°', zone: 'z1', code: 'Backquote' },
    { main: '1', shift: '+', zone: 'z1', code: 'Digit1' },
    { main: '2', shift: '"', zone: 'z2', code: 'Digit2' },
    { main: '3', shift: '*', zone: 'z3', code: 'Digit3' },
    { main: '4', shift: 'ç', zone: 'z4', code: 'Digit4' },
    { main: '5', shift: '%', zone: 'z4', code: 'Digit5' },
    { main: '6', shift: '&', zone: 'z5', code: 'Digit6' },
    { main: '7', shift: '/', zone: 'z5', code: 'Digit7' },
    { main: '8', shift: '(', zone: 'z6', code: 'Digit8' },
    { main: '9', shift: ')', zone: 'z7', code: 'Digit9' },
    { main: '0', shift: '=', zone: 'z8', code: 'Digit0' },
    { main: "'", shift: '?', zone: 'z8', code: 'Quote' },
    { main: '^', shift: '`', zone: 'z8', code: 'Equal' },
    { main: '⌫', isSpecial: true, width: '100px', zone: 'spec', code: 'Backspace' }
  ],
  [
    { main: 'Tab', isSpecial: true, width: '65px', zone: 'spec', code: 'Tab' },
    { main: 'q', shift: 'Q', zone: 'z1', code: 'KeyQ' },
    { main: 'w', shift: 'W', zone: 'z2', code: 'KeyW' },
    { main: 'e', shift: 'E', zone: 'z3', code: 'KeyE' },
    { main: 'r', shift: 'R', zone: 'z4', code: 'KeyR' },
    { main: 't', shift: 'T', zone: 'z4', code: 'KeyT' },
    { main: 'z', shift: 'Z', zone: 'z5', code: 'KeyZ' },
    { main: 'u', shift: 'U', zone: 'z5', code: 'KeyU' },
    { main: 'i', shift: 'I', zone: 'z6', code: 'KeyI' },
    { main: 'o', shift: 'O', zone: 'z7', code: 'KeyO' },
    { main: 'p', shift: 'P', zone: 'z8', code: 'KeyP' },
    { main: 'ü', shift: 'è', zone: 'z8', code: 'BracketLeft' },
    { main: '¨', shift: '!', zone: 'z8', code: 'BracketRight' },
    { main: '⏎', isSpecial: true, width: '85px', zone: 'spec', code: 'Enter' }
  ],
  [
    { main: 'Caps', isSpecial: true, width: '85px', zone: 'spec', code: 'CapsLock' },
    { main: 'a', shift: 'A', zone: 'z1', code: 'KeyA' },
    { main: 's', shift: 'S', zone: 'z2', code: 'KeyS' },
    { main: 'd', shift: 'D', zone: 'z3', code: 'KeyD' },
    { main: 'f', shift: 'F', zone: 'z4', code: 'KeyF' },
    { main: 'g', shift: 'G', zone: 'z4', code: 'KeyG' },
    { main: 'h', shift: 'H', zone: 'z5', code: 'KeyH' },
    { main: 'j', shift: 'J', zone: 'z5', code: 'KeyJ' },
    { main: 'k', shift: 'K', zone: 'z6', code: 'KeyK' },
    { main: 'l', shift: 'L', zone: 'z7', code: 'KeyL' },
    { main: 'ö', shift: 'é', zone: 'z8', code: 'Semicolon' },
    { main: 'ä', shift: 'à', zone: 'z8', code: 'Quote' },
    { main: '$', shift: '£', zone: 'z8', code: 'Backslash' }
  ],
  [
    { main: 'Shift', isSpecial: true, width: '110px', zone: 'spec', code: 'ShiftLeft' },
    { main: '<', shift: '>', zone: 'z1', code: 'IntlBackslash' },
    { main: 'y', shift: 'Y', zone: 'z2', code: 'KeyY' },
    { main: 'x', shift: 'X', zone: 'z3', code: 'KeyX' },
    { main: 'c', shift: 'C', zone: 'z4', code: 'KeyC' },
    { main: 'v', shift: 'V', zone: 'z4', code: 'KeyV' },
    { main: 'b', shift: 'B', zone: 'z5', code: 'KeyB' },
    { main: 'n', shift: 'N', zone: 'z5', code: 'KeyN' },
    { main: 'm', shift: 'M', zone: 'z6', code: 'KeyM' },
    { main: ',', shift: ';', zone: 'z7', code: 'Comma' },
    { main: '.', shift: ':', zone: 'z8', code: 'Period' },
    { main: '-', shift: '_', zone: 'z8', code: 'Slash' },
    { main: 'Shift', isSpecial: true, width: '110px', zone: 'spec', code: 'ShiftRight' }
  ],
  [
    { main: 'Ctrl', isSpecial: true, zone: 'spec', code: 'ControlLeft' },
    { main: 'Win', isSpecial: true, zone: 'spec', code: 'MetaLeft' },
    { main: 'Alt', isSpecial: true, zone: 'spec', code: 'AltLeft' },
    { main: 'Space', isSpecial: true, width: '320px', zone: 'daumen', code: 'Space' },
    { main: 'AltGr', isSpecial: true, zone: 'spec', code: 'AltRight' },
    { main: 'Win', isSpecial: true, zone: 'spec', code: 'MetaRight' },
    { main: 'Ctrl', isSpecial: true, zone: 'spec', code: 'ControlRight' }
  ]
];

const handleKeyDown = (e: KeyboardEvent) => {
  if (isFinished.value) return;
  activeKeys.value.add(e.code);
  if (['Tab', 'Alt', ' '].includes(e.key)) e.preventDefault();

  if (startTime.value === null && e.key.length === 1) {
    startTime.value = Date.now();
    emit('start');
  }

  if (e.key.length === 1 || e.key === ' ') {
    processKey(e.key);
    secretBuffer.value = (secretBuffer.value + e.key.toLowerCase()).slice(-secretPhrase.length);
    if (secretBuffer.value === secretPhrase) {
      showEasterEgg.value = true;
      setTimeout(() => { showEasterEgg.value = false; secretBuffer.value = ""; }, 7000);
    }
  } else if (e.key === 'Backspace') {
    currentIndex.value = Math.max(0, currentIndex.value - 1);
    hasErrorAtPosition.value = false;
  }
};

const processKey = (inputKey: string) => {
  const expected = props.gametext[currentIndex.value];
  if (inputKey === expected) {
    currentIndex.value++;

    emit('progress', currentIndex.value);

    lastWrongIndex.value = -1;
    hasErrorAtPosition.value = false;
    if (currentIndex.value === props.gametext.length) finishGame();
  } else {
    if (!hasErrorAtPosition.value) {
      totalMistakes.value++;
      hasErrorAtPosition.value = true;
    }
    lastWrongIndex.value = currentIndex.value;
    setTimeout(() => { lastWrongIndex.value = -1; }, 150);
  }
};

const finishGame = () => {
  isFinished.value = true;
  const timeTaken = (Date.now() - (startTime.value || Date.now())) / 1000;
  emit('finished', {
    realTime: timeTaken,
    mistakes: totalMistakes.value,
    adjustedTime: timeTaken + (totalMistakes.value * 3),
    wpm: Math.round((props.gametext.length / 5) / (timeTaken / 60))
  });
};

const handleKeyUp = (e: KeyboardEvent) => activeKeys.value.delete(e.code);

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown);
  window.addEventListener('keyup', handleKeyUp);
});
onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown);
  window.removeEventListener('keyup', handleKeyUp);
});
</script>

<template>
  <div class="typing-container">
    <div v-if="showEasterEgg" class="sahur-overlay">
      <div class="sahur-content">
        <img src="/secret.jpg" alt="SECRET" class="sahur-img">
        <h1 class="sahur-text">TUNG TUNG TUNG... SAHURRRRR!</h1>
      </div>
    </div>

    <div class="game-viewport">
      <div class="text-track" :style="{ transform: `translateX(calc(50% - ${currentIndex * charWidth}px - ${charWidth / 2}px))` }">
        <span v-for="(char, index) in gametext" :key="index" class="char" :class="{ 'correct': index < currentIndex, 'current': index === currentIndex, 'wrong': index === lastWrongIndex }">
          {{ char === ' ' ? '&nbsp;' : char }}
        </span>
      </div>
    </div>

    <div class="keyboard">
      <div v-for="(row, rowIndex) in keyboardlayout" :key="rowIndex" class="keyboard-row">
        <div
            v-for="(key, keyIndex) in row"
            :key="keyIndex"
            class="key"
            :class="[key.zone, { 'is-active': activeKeys.has(key.code) }]"
            :style="{ width: key.width }"
        >
          <span class="spot-top-left" v-if="key.shift">{{ key.shift }}</span>
          <span class="spot-bottom-left">{{ key.main }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;900&family=JetBrains+Mono:wght@500&display=swap');

.typing-container {
  background: #05080D;
  padding: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 50px;
  min-height: 100vh;
  font-family: 'Nunito', sans-serif;
}

.game-viewport {
  position: relative;
  width: 100%;
  max-width: 850px;
  height: 120px;
  background: #0B1117;
  border-radius: 20px;
  border: 1px solid #263640;
  overflow: hidden;
  display: flex;
  align-items: center;
}

.text-track {
  display: flex;
  transition: transform 0.12s cubic-bezier(0, 0.5, 0.5, 1);
  white-space: nowrap;
  font-family: 'JetBrains Mono', monospace;
  font-size: 2.2rem;
}

.char { width: 25px; display: inline-block; text-align: center; color: #3d4f66; }
.char.correct { color: #BF5B04; opacity: 0.6; }
.char.current { color: #ffffff; text-shadow: 0 0 10px white; }
.char.wrong { color: #ff4d4d; animation: shake 0.1s infinite; }

.keyboard {
  display: flex;
  flex-direction: column;
  gap: 8px;
  background: #0B1117;
  padding: 25px;
  border-radius: 18px;
  border: 1px solid #263640;
}

.keyboard-row {
  display: flex;
  flex-direction: row;
  gap: 6px;
  justify-content: center;
}

.key {
  position: relative;
  width: 52px;
  height: 52px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.05);
  display: flex;
  justify-content: center;
  align-items: center;
  transition: all 0.1s ease;
}

/* 10-Finger System Farben */
.z1, .z8 { background: rgba(52, 152, 219, 0.2); color: #3498db; }
.z2, .z7 { background: rgba(155, 89, 182, 0.2); color: #9b59b6; }
.z3, .z6 { background: rgba(231, 76, 60, 0.2); color: #e74c3c; }
.z4, .z5 { background: rgba(230, 126, 34, 0.2); color: #e67e22; }
.spec { background: #1c2730; color: #4a5d75; }
.daumen { background: #263640; color: #65768C; }

.key.is-active {
  background: #BF5B04 !important;
  color: white !important;
  transform: translateY(4px);
  box-shadow: 0 0 20px rgba(191, 91, 4, 0.8);
}

.spot-top-left { position: absolute; top: 6px; left: 8px; font-size: 0.7rem; opacity: 0.6; }
.spot-bottom-left { font-size: 1rem; font-weight: 800; }

.sahur-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: #000; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; }
.sahur-img { width: 500px; border-radius: 20px; border: 5px solid #BF5B04; animation: bounce 0.5s infinite; }
.sahur-text { color: white; font-size: 3rem; margin-top: 20px; font-family: 'Nunito'; font-weight: 900; text-shadow: 3px 3px 0 #BF5B04; }

@keyframes bounce { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.05); } }
@keyframes shake { 0%, 100% { transform: translateX(0); } 25% { transform: translateX(-3px); } 75% { transform: translateX(3px); } }
</style>
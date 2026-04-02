<script setup lang="ts">
import {computed, onMounted, onUnmounted, ref} from "vue";

const props = defineProps<{
  gametext: string

}>()

const currentIndex = ref(0);
const activeKeys = ref(new Set());
const currentInput = ref('');
const textCharacters = computed(() => {
  return props.gametext.split('').map((char, index) => ({
    char,
    status: index < currentIndex.value ? 'correct' : (index === currentIndex.value ? 'current' : 'pending')
  }));
});
const keyboardlayout = [
        [
          { main: '§', shift: '°', altGr: '' },
          { main: '1', shift: '+', altGr: '¦' },
          { main: '2', shift: '"', altGr: '@' },
          { main: '3', shift: '*', altGr: '#' },
          { main: '4', shift: 'ç', altGr: '¼' },
          { main: '5', shift: '%', altGr: '½' },
          { main: '6', shift: '&', altGr: '¬' },
          { main: '7', shift: '/', altGr: '|' },
          { main: '8', shift: '(', altGr: '¢' },
          { main: '9', shift: ')', altGr: '┤' },
          { main: '0', shift: '=', altGr: '' },
          { main: "'", shift: '?', altGr: '´' },
          { main: '^', shift: '`', altGr: '~' },
          { main: 'Backspace', isSpecial: true, width: '100px' }
        ],
        [
          { main: 'Tab', isSpecial: true, width: '60px' },
          { main: 'q', shift: 'Q', altGr: '@' },
          { main: 'w', shift: 'W', altGr: '' },
          { main: 'e', shift: 'E', altGr: '€' },
          { main: 'r', shift: 'R', altGr: '' },
          { main: 't', shift: 'T', altGr: '' },
          { main: 'z', shift: 'Z', altGr: '' },
          { main: 'u', shift: 'U', altGr: '' },
          { main: 'i', shift: 'I', altGr: '' },
          { main: 'o', shift: 'O', altGr: '' },
          { main: 'p', shift: 'P', altGr: '' },
          { main: 'ü', shift: 'è', altGr: '[' },
          { main: '¨', shift: '!', altGr: ']' },
          { main: 'Enter', isSpecial: true, width: '80px' }
        ],
        [
          { main: 'Caps', isSpecial: true, width: '80px' },
          { main: 'a', shift: 'A', altGr: '' },
          { main: 's', shift: 'S', altGr: '' },
          { main: 'd', shift: 'D', altGr: '' },
          { main: 'f', shift: 'F', altGr: '' },
          { main: 'g', shift: 'G', altGr: '' },
          { main: 'h', shift: 'H', altGr: '' },
          { main: 'j', shift: 'J', altGr: '' },
          { main: 'k', shift: 'K', altGr: '' },
          { main: 'l', shift: 'L', altGr: '' },
          { main: 'ö', shift: 'é', altGr: '{' },
          { main: 'ä', shift: 'à', altGr: '}' },
          { main: '$', shift: '£', altGr: '}' }
        ],
        [
          { main: 'Shift', isSpecial: true, width: '100px' },
          { main: '<', shift: '>', altGr: '\\' },
          { main: 'y', shift: 'Y', altGr: '' },
          { main: 'x', shift: 'X', altGr: '' },
          { main: 'c', shift: 'C', altGr: '' },
          { main: 'v', shift: 'V', altGr: '' },
          { main: 'b', shift: 'B', altGr: '' },
          { main: 'n', shift: 'N', altGr: '' },
          { main: 'm', shift: 'M', altGr: 'µ' },
          { main: ',', shift: ';', altGr: '' },
          { main: '.', shift: ':', altGr: '' },
          { main: '-', shift: '_', altGr: '' },
          { main: 'Shift', isSpecial: true, width: '100px' }
        ],
        [
          { main: 'Ctrl', isSpecial: true },
          { main: 'Win', isSpecial: true },
          { main: 'Alt', isSpecial: true },
          { main: 'Space', isSpecial: true, width: '300px' },
          { main: 'AltGr', isSpecial: true },
          { main: 'Win', isSpecial: true },
          { main: 'Menu', isSpecial: true },
          { main: 'Ctrl', isSpecial: true }
        ]
    ]


const handleKeyDown = (e: KeyboardEvent) => {
  if (e.code === 'Space') e.preventDefault();

  activeKeys.value.add(e.key);

  if (e.key.length === 1 || e.key === ' ') {
    processKey(e);
  } else {
    activeKeys.value.add(e.key);
  }
};

const handleKeyUp = (e: KeyboardEvent) => {
  activeKeys.value.delete(e.key);
  activeKeys.value.clear();
};

const isKeyActive = (keyObj: any) => {

  return activeKeys.value.has(keyObj.main) ||
      activeKeys.value.has(keyObj.shift) ||
      activeKeys.value.has(keyObj.altGr);
};

const processKey = (e: KeyboardEvent) => {
  const expectedChar = props.gametext[currentIndex.value];
  const inputChar = e.key === 'Space' ? ' ' : e.key;

  if (inputChar === expectedChar) {
    // Treffer!
    currentIndex.value++;
    // Hier später Sound oder Partikel triggern
  } else {
    // Fehler-Logik: Entweder blockieren oder rot markieren
    console.log("Falsche Taste!");
  }
};

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
{{ currentInput }}
  <div class="game-viewport">
    <div class="cursor-line"></div>

    <div
        class="text-track"
        :style="{ transform: `translateX(calc(50% - ${currentIndex * 25}px))` }"
    >
    <span
        v-for="(char, index) in gametext"
        :key="index"
        :class="{
        'char': true,
        'correct': index < currentIndex,
        'current': index === currentIndex
      }"
    >
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
          :class="{
      'special': key.isSpecial,
      'is-active': isKeyActive(key)
    }"
          :style="{ width: key.width }"
      >
        <span class="spot-top-left">{{ key.shift }}</span>
        <span class="spot-bottom-left">{{ key.main }}</span>
        <span class="spot-bottom-right">{{ key.altGr }}</span>
      </div>

    </div>
  </div>
</template>

<style scoped>
.game-viewport {
  position: relative;
  width: 100%;
  max-width: 800px;
  height: 100px;
  margin: 0 auto;
  overflow: hidden;
  display: flex;
  align-items: center;
  color: black;
}
.key {
  display: inline-flex;
  position: relative;
  width: 45px;
  height: 45px;
  margin: 2px;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: #f9f9f9;
  transition: all 0.05s ease; /* Schnelle Reaktion */
  user-select: none;
}

/* Der visuelle Ausschlag */
.key.is-active {
  background-color: #42b883; /* Vue-Grün */
  color: white;
  transform: translateY(3px); /* Taste "drückt" sich nach unten */
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
  border-color: #33a06f;
}

/* Positionierung der 3 Spots innerhalb der Taste */
.key span {
  position: absolute;
  font-size: 0.7rem;
}
.spot-top-left { top: 2px; left: 4px; }
.spot-bottom-left { bottom: 2px; left: 4px; font-size: 0.9rem !important; font-weight: bold; }
.spot-bottom-right { bottom: 2px; right: 4px; color: #666; }

.key.is-active .spot-bottom-right { color: #eee; }
</style>
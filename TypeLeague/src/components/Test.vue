<script setup lang="ts">
import { ref, onMounted } from 'vue'

import { supabase } from '../src/supabaseClient'

const eintraege = ref([])
const ladeFehler = ref(null)
const laedt = ref(true)

async function holeDaten() {
  laedt.value = true
  ladeFehler.value = null

  try {
    // Hier wird die Tabelle 'languages' abgefragt
    const { data, error } = await supabase
        .from('languages')
        .select('*')

    if (error) {
      throw error
    } else {
      eintraege.value = data
      console.log("Daten empfangen:", data)
    }
  } catch (err) {
    ladeFehler.value = err.message
    console.error("Fehler-Details:", err)
  } finally {
    laedt.value = false
  }
}

onMounted(() => {
  holeDaten()
})
</script>

<template>
  <div class="test-page">
    <div class="header">
      <h1>🛠 Datenbank-Test (test.vue)</h1>
      <button @click="holeDaten" class="refresh-btn">🔄 Aktualisieren</button>
    </div>

    <hr />

    <div v-if="ladeFehler" class="box error">
      <h3>🚫 Da lief etwas schief</h3>
      <p>{{ ladeFehler }}</p>
      <small>Tipp: Prüfe die RLS-Policies in Supabase!</small>
    </div>

    <div v-else-if="laedt" class="box loading">
      <div class="spinner"></div>
      <p>Verbindung zu PostgreSQL wird aufgebaut...</p>
    </div>

    <div v-else-if="eintraege.length > 0" class="results">
      <p class="success-msg">✅ {{ eintraege.length }} Einträge gefunden!</p>

      <div class="card-grid">
        <div v-for="item in eintraege" :key="item.id" class="data-card">
          <h3>{{ item.name || 'Kein "name" Feld' }}</h3>

          <p v-if="item.code"><strong>Code:</strong> {{ item.code }}</p>

          <div class="raw-data">
            <strong>Rohdaten:</strong>
            <pre>{{ item }}</pre>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="box empty">
      <p>Die Verbindung steht, aber die Tabelle <strong>'languages'</strong> enthält keine Daten.</p>
      <p>Füge im Supabase Dashboard unter "Table Editor" eine Zeile hinzu.</p>
    </div>
  </div>
</template>

<style scoped>
.test-page {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Inter', system-ui, sans-serif;
  background: #fdfdfd;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.refresh-btn {
  background: #3ecf8e;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  transition: opacity 0.2s;
}

.refresh-btn:hover { opacity: 0.8; }

.box {
  padding: 30px;
  text-align: center;
  border-radius: 12px;
  margin: 20px 0;
}

.error { background: #fff5f5; border: 2px solid #feb2b2; color: #c53030; }
.loading { background: #f7fafc; border: 2px solid #e2e8f0; }
.empty { background: #fffaf0; border: 2px solid #fbd38d; }

.success-msg { color: #2f855a; font-weight: bold; margin-bottom: 20px; }

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.data-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.raw-data {
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px dashed #cbd5e0;
}

pre {
  background: #2d3748;
  color: #a0aec0;
  padding: 10px;
  border-radius: 5px;
  font-size: 0.75rem;
  overflow-x: auto;
  margin-top: 5px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e2e8f0;
  border-top: 4px solid #3ecf8e;
  border-radius: 50%;
  margin: 0 auto 10px;
  animation: spin 1s linear infinite;
}

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>
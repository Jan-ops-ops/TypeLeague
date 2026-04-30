<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";

const router = useRouter();
const { locale, t } = useI18n();
const username = ref('');
const email = ref('');
const password = ref('');
const error = ref('');

onMounted(async () => {
  const savedUser = localStorage.getItem('user');
  if (savedUser) {
    await router.push('/');
  }
});

const register = async () => {
  try {
    error.value = '';

    if (!username.value || !email.value || !password.value) {
      error.value = t('tregisterpage.errorEmpty');
      return;
    }

    if (!email.value.includes('@')) {
      error.value = t('tregisterpage.errorEmail');
      return;
    }

    const langMap: Record<string, number> = { 'en': 1, 'de': 2, 'fr': 3 };
    const selectedLangId = langMap[locale.value] || 1;

    const response = await fetch('/api/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: username.value,
        password: password.value,
        email: email.value,
        languageId: selectedLangId
      })
    });

    if (response.ok) {
      localStorage.setItem('user', JSON.stringify({ name: username.value }));
      await router.push("/");
    } else {
      const data = await response.json();
      error.value = data.message || t('tregisterpage.errorFailed');
    }
  } catch (e) {
    error.value = "Serververbindung fehlgeschlagen";
  }
};
</script>

<template>
  <div class="register-page">
    <form class="register-form" @submit.prevent="register">
      <div class="header">
        <h1>{{ $t('tregisterpage.title') }}</h1>
      </div>

      <label>{{ $t('tregisterpage.username') }}</label>
      <input v-model="username" id="input" :placeholder="$t('tregisterpage.enterusername')" required>

      <label>{{ $t('tregisterpage.email') }}</label>
      <input v-model="email" type="email" id="input" :placeholder="$t('tregisterpage.enteremail')" required>

      <label>{{ $t('tregisterpage.password') }}</label>
      <input v-model="password" type="password" id="input" :placeholder="$t('tregisterpage.enterpassword')" required>

      <p v-if="error" class="error">{{ error }}</p>

      <button type="submit" class="register-button">
        {{ $t('tregisterpage.registerbutton') }}
      </button>

      <div class="footer">
        <router-link to="/login" class="sub-link">{{ $t('tregisterpage.haveaccount') }}</router-link>
      </div>
    </form>
  </div>
</template>

<style scoped>

.register-page {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #05080D;
  font-family: 'Nunito', sans-serif;
}

.register-form {
  width: 100%;
  max-width: 380px;
  background: #0B1117;
  padding: 40px;
  border-radius: 12px;
  border: 1px solid #263640;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.header {
  margin-bottom: 20px;
  text-align: left;
}

h1 {
  font-size: 2rem;
  font-weight: 800;
  color: white;
  margin: 0;
}

label {
  color: #65768C;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-top: 6px;
}

#input {
  background: #121820;
  border: 1px solid #263640;
  padding: 12px 14px;
  border-radius: 8px;
  color: white;
  font-family: 'Nunito', sans-serif;
  font-weight: 600;
  font-size: 1rem;
  transition: 0.2s ease;
}

#input:focus {
  outline: none;
  border-color: #BF5B04;
}

.register-button {
  margin-top: 20px;
  padding: 14px;
  background: #BF5B04;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: 0.3s;
}

.register-button:hover {
  background: #733917;
}

.footer {
  margin-top: 15px;
  text-align: center;
}

.sub-link {
  color: #65768C;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
}

.sub-link:hover {
  color: #BF5B04;
}

.error {
  color: #ff4d4d;
  font-size: 0.8rem;
  text-align: center;
  font-weight: 600;
}
</style>
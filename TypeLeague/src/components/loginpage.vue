<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import bcrypt from 'bcryptjs';

const router = useRouter();
const { t } = useI18n();

const username = ref('');
const password = ref('');
const error = ref('');

const login = async () => {
  try {
    if (!username.value || !password.value) {
      error.value = t('tloginpage.errorEmpty');
      return;
    }

    const storedUser = localStorage.getItem('user_db');

    if (storedUser) {
      const user = JSON.parse(storedUser);
      const isMatch = await bcrypt.compare(password.value, user.password);

      if (user.username === username.value && isMatch) {
        localStorage.setItem('user', JSON.stringify({ name: user.username }));
        await router.push("/");
      } else {
        error.value = t('tloginpage.errorWrong');
      }
    } else {
      error.value = t('tloginpage.errorNotFound');
    }
  } catch (e) {
    error.value = "Login Error";
  }
};
</script>

<template>
  <div class="login-page">
    <div class="auth-box">
      <header>
        <h1>{{ $t('tloginpage.title') }}</h1>
      </header>

      <form class="login-form" @submit.prevent="login">
        <div class="input-group">
          <label>{{ $t('tloginpage.username') }}</label>
          <input
              v-model="username"
              type="text"
              :placeholder="$t('tloginpage.enterusername')"
              required
          >
        </div>

        <div class="input-group">
          <label>{{ $t('tloginpage.password') }}</label>
          <input
              v-model="password"
              type="password"
              :placeholder="$t('tloginpage.enterpassword')"
              required
          >
        </div>

        <p v-if="error" class="error-msg">{{ error }}</p>

        <button type="submit" class="auth-btn">
          {{ $t('tloginpage.loginbutton') }}
        </button>
      </form>

      <footer>
        <router-link to="/register" class="sub-link">
          {{ $t('tloginpage.noaccount') }}
        </router-link>
      </footer>
    </div>
  </div>
</template>

<style scoped>


.login-page {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #05080D;
  font-family: 'Nunito', sans-serif;
}

.auth-box {
  width: 100%;
  max-width: 380px;
  background: #0B1117;
  padding: 40px;
  border-radius: 12px;
  border: 1px solid #263640;
}

header {
  margin-bottom: 30px;
  text-align: left;
}

h1 {
  font-size: 2rem;
  font-weight: 800;
  color: white;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

label {
  color: #65768C;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
}

input {
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

input:focus {
  outline: none;
  border-color: #BF5B04;
}

.auth-btn {
  margin-top: 10px;
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

.auth-btn:hover {
  background: #733917;
}

footer {
  margin-top: 25px;
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

.error-msg {
  color: #ff4d4d;
  font-size: 0.8rem;
  text-align: center;
  font-weight: 600;
}
</style>
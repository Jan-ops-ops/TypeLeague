<script setup lang="ts">
import {onMounted, ref} from "vue";
import {useRouter} from "vue-router";
import bcrypt from 'bcryptjs';

const router = useRouter();
const username = ref('');
const email = ref('');
const password = ref('');
const language = ref('de');
const error = ref('');
const saltrounds = 12;

onMounted(
    async () => {
      const savedUser = localStorage.getItem('loggedUser');
      if (savedUser) {
        await router.push('/products')
      }}
);

const register = async () => {
  try {
    if (username.value == '' || email.value == '' || password.value == '' || language.value == '') return;
    if (!email.value.includes('@') || !email.value.includes('.'))
    {
      error.value = 'email muss @ und . beinhalten'
      return;
    }
    const hashedPW = bcrypt.hashSync(password.value, saltrounds );

    // neuer user

      localStorage.setItem('user', JSON.stringify({name: username.value, email: email.value, lang: language.value }));
      await router.push("/");
  }
  catch (error) {
    console.error(error);
  }
}


</script>

<template>
  <div class="register-page">
    <form class="register-form" @submit.prevent="register">
      <div class="header">
        <span>Willkommen bei <b>beSmart AG</b> </span>
        <a href="/login" ><br>haben sie schon einen account?</a>
      </div>

      <label>Benutzername</label>
      <input type="email" v-model="username" id="input" placeholder="geben Sie ihren Benutzernamen ein">
      <label>Vorname</label>
      <input v-model="firstname" id="input" placeholder="geben Sie ihren Vornamen ein">
      <label>Nachnamen</label>
      <input v-model="lastname" id="input" placeholder="geben Sie ihren Nachnamen ein">
      <label>Passwort</label>
      <input type="password" v-model="password" id="input" placeholder="geben Sie ein Passwort ein">
      <label>Sprache</label>
      <select v-model="language" id="input">
        <option value="de">Deutsch</option>
        <option value="en">Englisch</option>
        <option value="fr">Französisch</option>
      </select>
      <p class="error"> {{ error }}</p>
      <button type="submit" class="register-button">Registrieren</button>
    </form>
  </div>
</template>

<style scoped>

</style>
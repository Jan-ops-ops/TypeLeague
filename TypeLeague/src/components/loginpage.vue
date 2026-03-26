<script setup lang="ts">

import {onMounted, ref} from "vue";
import {useRouter} from "vue-router";
import bcrypt from 'bcryptjs';


const router = useRouter();
const username = ref('')
const password = ref('')
const tried_password = ref('')
const tried_username = ref('')
const error = ref('')

onMounted(
    async () => {
      const savedUser = localStorage.getItem('loggedUser');
      if (savedUser) {
        await router.push('/')
      }}
);

const login = async () => {
  try {
    if (username.value == '' || password.value == '') return;
    if (password.value == tried_password.value && username == tried_username) return;

    const pulledPW = "";
    const pulledemail = "";
    const pulledlang = "";

    const isMatch = await bcrypt.compare(password.value, pulledPW);

    if (isMatch) {
      localStorage.setItem('user', JSON.stringify({name : username.value, email : pulledemail, lang : pulledlang }));
      await router.push("/");
    } else {
      error.value = 'Passwort oder Benutzername Falsch'
      tried_password.value = password.value
      tried_username.value = username.value
    }

  } catch (e) {
    console.log(error)
    tried_password.value = password.value
    tried_username.value = username.value
  }
}


</script>

<template>
  <div class="login-page">
    <form class="login-form" @submit.prevent="login">
      <div class="header">
        <span>Willkommen zurück bei <b>beSmart AG</b> </span>
        <a href="/register" ><br>haben sie noch kein account?</a>
      </div>

      <label>Benutzername</label>
      <input type="email" v-model="username" id="input" placeholder="geben Sie ihren Benutzernamen ein">
      <label>Passwort</label>
      <input type="password" v-model="password" id="input" placeholder="geben Sie ein Passwort ein">
      <p class="error"> {{ error}}</p>
      <button type="submit" class="login-button">LOGIN</button>

    </form>
  </div>
</template>

<style scoped>

</style>
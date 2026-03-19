import { createRouter, createWebHistory } from 'vue-router'
import Homepage from "../components/homepage.vue";
import Registerpage from "../components/registerpage.vue";
import Loginpage from "../components/loginpage.vue";


const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'home',
            component: Homepage
        },
        {
            path: '/login',
            name: 'login',
            component: Loginpage
        },
        {
            path: '/register',
            name: 'register',
            component: Registerpage
        },
    ]
})


export default router

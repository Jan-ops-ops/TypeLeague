import { createRouter, createWebHistory } from 'vue-router'
import Homepage from "../components/homepage.vue";
import Registerpage from "../components/registerpage.vue";
import Loginpage from "../components/loginpage.vue";
import StatsPage from "../components/StatsPage.vue";
import RoadmapPage from "../components/RoadmapPage.vue";
import LeaguePage from "../components/LeaguePage.vue";
import TrainingPage from "../components/TrainingPage.vue";
import LeaderboardPage from "../components/LeaderboardPage.vue";
import Roadmaptyping from "../components/Roadmaptyping.vue";


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
        {
            path: '/stats',
            name: 'stats',
            component: StatsPage
        },
        {
            path: '/roadmap',
            name: 'roadmap',
            component: RoadmapPage
        },
        {
            path: '/league',
            name: 'league',
            component: LeaguePage
        },
        {
            path: '/training',
            name: 'training',
            component: TrainingPage
        },
        {
            path: '/leaderboard',
            name: 'leaderboard',
            component: LeaderboardPage
        },
        {
            path: '/stats',
            name: 'stats',
            component: StatsPage
        },
        {
            path: '/Roadmaptyping/:id',
            name: 'Roadmaptyping',
            component: Roadmaptyping
        }
    ]
})


export default router

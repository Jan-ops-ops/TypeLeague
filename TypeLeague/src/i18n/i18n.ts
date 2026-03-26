import { createI18n } from 'vue-i18n';

const messages = {
    en: {
        greeting: {
            message: "Welcome to TypeLeague",
            description: "Here your fingers are your weapons."
        },
        navbar: {
            login: "Login",
            register: "Register",
            logout: "Logout",
            roadmap: "Roadmap",
            league: "League",
            leaderboard: "Leaderboard",
            stats: "Stats",
            training: "Training"
        }
    },
    de: {
        greeting: {
            message: "Wilkommen zu TypeLeague",
            description: "Hier sind deine Finger deine Waffen."
        },
        navbar: {
            login: "Einloggen",
            register: "Registrieren",
            logout: "Ausloggen",
            roadmap: "Levelpfad",
            league: "Liga",
            leaderboard: "Rangliste",
            stats: "Statistiken",
            training: "Training"
        }
    },
    fr: {
        greeting: {
            message: "Bienvenue sur TypeLeague",
            description: "Ici, vos doigts sont vos armes.",
        },
        navbar: {
            login: "Connexion",
            register: "Inscription",
            logout: "Déconnexion",
            roadmap: "Feuille de route",
            league: "Ligue",
            leaderboard: "Classement",
            stats: "Statistiques",
            training: "Entraînement"

        }
    }
};




export const i18n = createI18n({
    legacy: false,
    locale: 'en',
    fallbackLocale: 'en',
    messages
});
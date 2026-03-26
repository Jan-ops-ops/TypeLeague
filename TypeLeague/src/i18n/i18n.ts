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
        },
        tloginpage: {
            welcomeback: "Welcome back to ",
            noaccount: "Don't have an account yet?",
            username: "Please enter your username",
            password: "Please enter your password",
            loginbutton: "Login"

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
        },
        tloginpage: {
            welcomeback: "Willkommen zurück bei ",
            noaccount: "Du hast noch keinen Account?",
            username: "Bitte gib deinen Benutzernamen ein",
            password: "Bitte gib dein Passwort ein",
            loginbutton: "Einloggen"
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

        },
        tloginpage: {
            welcomeback: "Bon retour sur ",
            noaccount: "Vous n'avez pas encore de compte ?",
            username: "Veuillez entrer votre nom d'utilisateur",
            password: "Veuillez entrer votre mot de passe",
            loginbutton: "Se connecter"
        }

    }
};




export const i18n = createI18n({
    legacy: false,
    locale: 'en',
    fallbackLocale: 'en',
    messages
});
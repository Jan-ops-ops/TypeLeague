import { createI18n } from 'vue-i18n';

const messages = {
    en: {
        homepage: {
            description: "TypeLeague is a platform where you can improve your typing speed and build your skills step by step. Train efficiently, track your progress, and become faster than ever.",
            why: "We created TypeLeague to make learning easier and more motivating. Instead of boring practice, you get structure and real progress.",
            competitive: "Challenge other players in real-time typing competitions and see who's the fastest!",
            roadmapCTA: "Start the Roadmap now and improve your skills"
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
            title: "Login",
            noaccount: "Don't have an account yet?",
            username: "Username",
            password: "Password",
            enterusername: "Please enter your username",
            enterpassword: "Please enter your password",
            loginbutton: "Login",
            logoutbutton: "Logout",
            errorEmpty: "Please fill in all fields",
            errorNotFound: "User not found",
            errorWrong: "Incorrect username or password"
        },
        tregisterpage: {
            title: "Create Account",
            haveaccount: "Already have an account?",
            username: "Username",
            email: "Email",
            password: "Password",
            enterusername: "Enter your username",
            enteremail: "Enter your email",
            enterpassword: "Enter your password",
            registerbutton: "Register",
            errorEmpty: "Fields cannot be empty",
            errorEmail: "Invalid email address",
            errorFailed: "Registration failed"
        }
    },
    de: {
        homepage: {
            description: "TypeLeague ist eine Plattform, auf der du deine Tippgeschwindigkeit verbessern und deine Fähigkeiten Schritt für Schritt entwickeln kannst. Trainiere gezielt, verfolge deinen Fortschritt und werde schneller als je zuvor.",
            why: "Wir haben TypeLeague entwickelt, um Lernen einfacher und motivierender zu machen. Statt langweiligem Üben bekommst du eine klare Struktur und echte Fortschritte.",
            competitive: "Tritt gegen andere Spieler in Echtzeit-Tippwettbewerben an und finde heraus, wer am schnellsten ist!",
            roadmapCTA: "Starte jetzt mit der Roadmap und verbessere deine Skills"
        },
        navbar: {
            login: "Einloggen",
            register: "Registrieren",
            logout: "Ausloggen",
            roadmap: "Roadmap",
            league: "Liga",
            leaderboard: "Rangliste",
            stats: "Statistiken",
            training: "Training"
        },
        tloginpage: {
            title: "Anmelden",
            noaccount: "Du hast noch keinen Account?",
            username: "Benutzername",
            password: "Passwort",
            enterusername: "Bitte gib deinen Benutzernamen ein",
            enterpassword: "Bitte gib dein Passwort ein",
            loginbutton: "Einloggen",
            logoutbutton: "Abmelden",
            errorEmpty: "Bitte fülle alle Felder aus",
            errorNotFound: "Benutzer nicht gefunden",
            errorWrong: "Benutzername oder Passwort falsch"
        },
        tregisterpage: {
            title: "Registrieren",
            haveaccount: "Hast du schon einen Account?",
            username: "Benutzername",
            email: "Email",
            password: "Passwort",
            enterusername: "Bitte gib deinen Benutzernamen ein",
            enteremail: "Bitte gib deine Email ein",
            enterpassword: "Bitte gib dein Passwort ein",
            registerbutton: "Registrieren",
            errorEmpty: "Felder dürfen nicht leer sein",
            errorEmail: "Ungültige E-Mail Adresse",
            errorFailed: "Fehler bei der Registrierung"
        }
    },
    fr: {
        homepage: {
            description: "TypeLeague est une plateforme qui te permet d'améliorer ta vitesse de frappe et de développer tes compétences étape par étape. Entraîne-toi efficacement, suis ta progression et deviens plus rapide que jamais.",
            why: "Nous avons créé TypeLeague pour rendre l'apprentissage plus simple et motivant. Au lieu d'exercices ennuyeux, tu avances avec une vraie structure.",
            competitive: "Affronte d'autres joueurs dans des compétitions de frappe en temps réel et découvre qui est le plus rapide !",
            roadmapCTA: "Commence la feuille de route maintenant et améliore tes compétences"
        },
        navbar: {
            login: "Connexion",
            register: "Inscription",
            logout: "Déconnexion",
            roadmap: "Roadmap",
            league: "Ligue",
            leaderboard: "Classement",
            stats: "Statistiques",
            training: "Training"
        },
        tloginpage: {
            title: "Connexion",
            noaccount: "Vous n'avez pas encore de compte ?",
            username: "Nom d'utilisateur",
            password: "Mot de passe",
            enterusername: "Veuillez entrer votre nom d'utilisateur",
            enterpassword: "Veuillez entrer votre mot de passe",
            loginbutton: "Se connecter",
            logoutbutton: "Se déconnecter",
            errorEmpty: "Veuillez remplir tous les champs",
            errorNotFound: "Utilisateur non trouvé",
            errorWrong: "Nom d'utilisateur ou mot de passe incorrect"
        },
        tregisterpage: {
            title: "Inscription",
            haveaccount: "Vous avez déjà un compte ?",
            username: "Nom d'utilisateur",
            email: "Email",
            password: "Mot de passe",
            enterusername: "Veuillez entrer votre nom d'utilisateur",
            enteremail: "Veuillez entrer votre email",
            enterpassword: "Veuillez entrer votre mot de passe",
            registerbutton: "S'inscrire",
            errorEmpty: "Les champs ne peuvent pas être vides",
            errorEmail: "Adresse e-mail invalide",
            errorFailed: "Échec de l'inscription"
        }
    }
};

export const i18n = createI18n({
    legacy: false,
    locale: 'en',
    fallbackLocale: 'en',
    messages
});
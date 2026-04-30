const express = require('express');
const session = require('express-session');
const pgSession = require('connect-pg-simple')(session);
require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const cors = require('cors');

const app = express();
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
    ssl: {
        rejectUnauthorized: false // Wichtig für Supabase/Render/Heroku
    }
});

app.use(express.json());
app.use(cors({ origin: 'http://localhost:5173', credentials: true }));

app.use(session({
    store: new pgSession({ pool, tableName: 'session' }),
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: 30 * 24 * 60 * 60 * 1000,
        httpOnly: true,
        secure: false,
        sameSite: 'lax'
    }
}));

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const query = `
            SELECT u.*, l.acronym
            FROM users u
            LEFT JOIN languages l ON u.fk_languagesid = l.languagesid
            WHERE u.username = $1
        `;

        const result = await pool.query(query, [username]);
        const user = result.rows[0];

        if (user && await bcrypt.compare(password, user.password)) {
            req.session.userId = user.userId;
            req.session.username = user.username;
            req.session.language = user.acronym;

            res.json({
                message: 'Eingeloggt',
                username: user.username,
                language: user.acronym
            });
        } else {
            res.status(401).json({ message: 'Falsche Zugangsdaten' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Fehler beim Login' });
    }
});

app.post('/api/register', async (req, res) => {
    const { username, password, email, languageId } = req.body;

    if (!username || !password || !email || !languageId) {
        return res.status(400).json({ message: 'Alle Felder ausfüllen' });
    }

    try {
        const hash = await bcrypt.hash(password, 10);
        await pool.query(
            'INSERT INTO users (username, password, email, fk_languagesid) VALUES ($1, $2, $3, $4)',
            [username, hash, email, languageId]
        );
        res.status(201).json({ message: 'User erstellt' });
    } catch (err) {
        console.error(err);
        res.status(400).json({ message: 'Registrierung fehlgeschlagen (Username oder Email vergeben)' });
    }
});

app.listen(3000, () => console.log('Server läuft auf Port 3000'));
create table levels
(
levelId serial primary key,
length int,
content text,
mistakes int
);

create table languages
(
languagesId serial primary key,
name Text,
acronym char(2)
);

create table wordlist
(
wordID serial primary key,
word text[],
difficulty int,
fk_languagesId INTEGER REFERENCES languages(languagesId)
);

create table users
(userId serial primary key,
username varchar(12),
password text,
email text,
elo INTEGER DEFAULT 1000
fk_languagesId INTEGER REFERENCES languages(languagesId)
);
create table plays
(
playId serial primary key,
points INTEGER,
mistakes INTEGER,
time int,
adjusted_time INT, -- time + (mistakes * 3)
wpm INT,
elo_change INT,
fk_userId INTEGER REFERENCES users(userId),
fk_wordId INTEGER REFERENCES wordlist(wordId),
fk_matchId INTEGER REFERENCES matches(matchId)
);

create table matches
(
    matchId serial primary key,
	winner_id INTEGER REFERENCES users(userId),
    match_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

create table user_level
(
user_levelId serial primary key,
completed boolean,
fk_userId INTEGER REFERENCES users(userId),
fk_levelId INTEGER REFERENCES levels(levelId)
);
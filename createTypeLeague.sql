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
fk_languagesId INTEGER REFERENCES languages(languagesId)
);
create table plays
(playId serial primary key,
points INTEGER,
mistakes INTEGER,
time int,
fk_userId INTEGER REFERENCES users(userId),
fk_wordId INTEGER REFERENCES wordlist(wordId)
);

create table user_level
(
user_levelId serial primary key,
completed boolean,
fk_userId INTEGER REFERENCES users(userId),
fk_levelId INTEGER REFERENCES levels(levelId)
);
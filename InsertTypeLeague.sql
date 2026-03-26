INSERT INTO languages (name, acronym) VALUES
('English', 'en'),
('Deutsch', 'de'),
('Français', 'fr');

INSERT INTO users(username,password,email,fk_languagesId) VALUES
('noelprotyper','$2a$12$IS1YOCLb2x9At/KgHy3lhe.nYf9TfPvIko77EzRnnYIA1thfhHHW.','noel@wengsi.com', 3),
('liambueno','$2a$12$IS1YOCLb2x9At/KgHy3lhe.nYf9TfPvIko77EzRnnYIA1thfhHHW.','liambu@eno.ch',2),
('kenanski','$2a$12$1hEoYBVswhTApY3dZoUMfeHKnnxtc2jt9PBcFN0Fb.9a96JbXDb5W','kenan@thailand.th',1 ),
('test','$2a$12$G7bhOFlzzA3mFSALubgnPOlHVSh6rzCu6gej0WT78UzKojzckCHf6','test@test.ch',2 );




INSERT INTO wordlist (difficulty, fk_languagesId, word) VALUES
(1, 2, ARRAY[
    'Ei', 'Ast', 'Zug', 'Hut', 'Uhr', 'Tag', 'See', 'Tor', 'Axt', 'Bad',
    'Eis', 'Opa', 'Oma', 'Elf', 'Rad', 'Rat', 'Tat', 'Mut', 'Wut', 'Lob',
    'Baum', 'Haus', 'Kind', 'Geld', 'Hand', 'Brot', 'Kopf', 'Wind', 'Berg', 'Wald',
    'Blau', 'Rot', 'Gelb', 'Grün', 'Kalt', 'Warm', 'Sonne', 'Mond', 'Stern', 'Erde',
    'Auto', 'Boot', 'Bahn', 'Flug', 'Weg', 'Ziel', 'Spiel', 'Sieg', 'Lauf', 'Zeit'
]),
(2, 2, ARRAY[
    'Apfel', 'Birne', 'Stuhl', 'Tisch', 'Lampe', 'Stadt', 'Land', 'Fluss', 'Abend', 'Nacht',
    'Vogel', 'Pferd', 'Hund', 'Katze', 'Maus', 'Schule', 'Lehrer', 'Klasse', 'Buch', 'Stift',
    'Farbe', 'Musik', 'Sport', 'Radio', 'Kaffee', 'Wasser', 'Zucker', 'Suppe', 'Kuchen', 'Sommer',
    'Winter', 'Woche', 'Monat', 'Jahr', 'Regen', 'Schnee', 'Wolke', 'Sturm', 'Blitz', 'Brief',
    'Karte', 'Handy', 'Anruf', 'Frage', 'Wissen', 'Denken', 'Fahren', 'Gehen', 'Lachen', 'Singen'
]),
(3, 2, ARRAY[
    'Frühling', 'Herbst', 'Garten', 'Fenster', 'Zukunft', 'Freiheit', 'Gedanke', 'Hoffnung', 'Glaube', 'Liebe',
    'Bahnhof', 'Flugzeug', 'Fahrrad', 'Autobahn', 'Parkplatz', 'Computer', 'Tastatur', 'Monitor', 'Software', 'Internet',
    'Zeitung', 'Magazin', 'Fernsehen', 'Kamera', 'Telefon', 'Ordnung', 'Leistung', 'Erfolg', 'Geduld', 'Freude',
    'Kleidung', 'Schrank', 'Spiegel', 'Teppich', 'Vorhang', 'Frühstück', 'Mittag', 'Abendessen', 'Getränk', 'Gemüse',
    'Einkauf', 'Geschenk', 'Feiertag', 'Besuch', 'Urlaub', 'Nachbar', 'Freund', 'Familie', 'Hochzeit', 'Kindheit'
]),
(4, 2, ARRAY[
    'Gesellschaft', 'Kühlschrank', 'Wissenschaft', 'Erfahrung', 'Abenteuer', 'Vertrauen', 'Sicherheit', 'Verbindung', 'Entwicklung', 'Erfindung',
    'Universität', 'Ausbildung', 'Vorstellung', 'Bedeutung', 'Verständnis', 'Möglichkeit', 'Wirklichkeit', 'Unterschied', 'Beziehung', 'Eigenschaft',
    'Mannschaft', 'Wettbewerb', 'Ergebnis', 'Teilnahme', 'Organisation', 'Vorbereitung', 'Entscheidung', 'Verantwortung', 'Gerechtigkeit', 'Höflichkeit',
    'Sonnenschein', 'Regenschirm', 'Gewitter', 'Jahreszeit', 'Landschaft', 'Krankenhaus', 'Apotheke', 'Arztpraxis', 'Gesundheit', 'Ernährung',
    'Fluggesellschaft', 'Versicherung', 'Sparkasse', 'Finanzamt', 'Postleitzahl', 'Wörterbuch', 'Schreibmaschine', 'Taschenlampe', 'Staubsauger', 'Büroklammer'
]),
(5, 2, ARRAY[
    'Geschwindigkeitsrausch', 'Aufmerksamkeitsspanne', 'Hintergrundbild', 'Umweltverschmutzung', 'Verschwörungstheorie',
    'Donaudampfschifffahrt', 'Rindfleischetikettierung', 'Eichhörnchenschweif', 'Streichholzschachtel', 'Lebensmittelqualität',
    'Arbeitslosengeld', 'Wirtschaftswachstum', 'Bundesregierung', 'Landwirtschaft', 'Klimaveränderung',
    'Verkehrsteilnehmer', 'Sicherheitsdienst', 'Krankenversicherung', 'Wohnungsmarkt', 'Infrastruktur',
    'Hochschulstudium', 'Forschungsprojekt', 'Technologiezentrum', 'Informationsfluss', 'Kommunikation',
    'Präsentationsstil', 'Konkurrenzkampf', 'Marktwirtschaft', 'Finanzierung', 'Investition',
    'Rechtsschutzversicherung', 'Telekommunikation', 'Energiegewinnung', 'Nachhaltigkeit', 'Verantwortung',
    'Gerechtigkeit', 'Entscheidung', 'Entwicklung', 'Organisation', 'Kooperation',
    'Leistungsfähigkeit', 'Produktivität', 'Motivation', 'Konzentration', 'Disziplin',
    'Kreativität', 'Phantasie', 'Intelligenz', 'Erfahrungswert', 'Wissensdurst'
]);


INSERT INTO wordlist (difficulty, fk_languagesId, word) VALUES
(1, 1, ARRAY[
    'Cat', 'Dog', 'Sun', 'Red', 'Big', 'Sky', 'Cup', 'Box', 'Run', 'Ten',
    'Fly', 'Ice', 'Egg', 'Tea', 'Car', 'Bus', 'Map', 'Hat', 'Pen', 'Bad',
    'Blue', 'Tree', 'Book', 'Fire', 'Wind', 'Moon', 'Star', 'Fish', 'Bird', 'Boat',
    'Milk', 'Rice', 'Meat', 'Cold', 'Warm', 'Fast', 'Slow', 'High', 'Low', 'Door',
    'Wall', 'Roof', 'Yard', 'Road', 'Park', 'Town', 'Home', 'Work', 'Boy', 'Girl'
]),
(2, 1, ARRAY[
    'House', 'Apple', 'Water', 'Bread', 'Smile', 'Green', 'River', 'Stone', 'Light', 'Night',
    'Table', 'Chair', 'Phone', 'Music', 'Cloud', 'Watch', 'Lunch', 'Sugar', 'Fruit', 'Money',
    'School', 'Garden', 'Winter', 'Summer', 'Coffee', 'Window', 'Father', 'Mother', 'Friend', 'Street',
    'Orange', 'Animal', 'Letter', 'Bottle', 'Camera', 'Bridge', 'Answer', 'Person', 'Market', 'Ticket',
    'Spring', 'Forest', 'Silver', 'Lesson', 'Moment', 'Dinner', 'Doctor', 'Worker', 'Castle', 'Action'
]),
(3, 1, ARRAY[
    'Weather', 'Library', 'Country', 'Journey', 'Picture', 'Believe', 'Morning', 'Evening', 'History', 'Example',
    'Student', 'Station', 'Village', 'Thought', 'Program', 'Science', 'Kitchen', 'Bedroom', 'Subject', 'Officer',
    'Mountain', 'Business', 'Calendar', 'Daughter', 'Hospital', 'Language', 'Personal', 'Question', 'Remember', 'Standard',
    'Tomorrow', 'Together', 'Building', 'Computer', 'Strength', 'Distance', 'Birthday', 'Interest', 'Painting', 'Movement',
    'Chocolate', 'Condition', 'Direction', 'Education', 'Operation', 'President', 'Structure', 'Transport', 'Vegetable', 'Attention'
]),
(4, 1, ARRAY[
    'Celebration', 'Everything', 'Experience', 'Information', 'Different', 'Discovery', 'Important', 'Knowledge', 'Management', 'Opportunity',
    'Performance', 'Production', 'Technology', 'University', 'Beautiful', 'Challenge', 'Character', 'Community', 'Decision', 'Determine',
    'Difficult', 'Direction', 'Economics', 'Effective', 'Equipment', 'Evidence', 'Exercise', 'Financial', 'Following', 'Framework',
    'Happiness', 'Influence', 'Inventory', 'Marketing', 'Mechanism', 'Necessary', 'Objective', 'Passenger', 'Political', 'Potential',
    'Presence', 'Pressure', 'Principle', 'Priority', 'Procedure', 'Professor', 'Property', 'Religious', 'Solution', 'Specific'
]),
(5, 1, ARRAY[
    'Responsibility', 'Congratulations', 'Identification', 'Transportation', 'Sustainability', 'Architecture', 'Communication', 'Understanding', 'International', 'Environmental',
    'Neighborhood', 'Relationship', 'Organization', 'Development', 'Achievement', 'Competition', 'Traditional', 'Professional', 'Significant', 'Perspective',
    'Individual', 'Background', 'Investment', 'Commercial', 'Discussion', 'Possibility', 'Atmosphere', 'Exhibition', 'Instruction', 'Generation',
    'Confidence', 'Maintenance', 'Resolution', 'Comparison', 'Literature', 'Association', 'Application', 'Coefficient', 'Description', 'Engineering',
    'Interaction', 'Negotiation', 'Observation', 'Preparation', 'Recognition', 'Requirement', 'Temperature', 'Alternative', 'Collections', 'Psychology'
]);


INSERT INTO wordlist (difficulty, fk_languagesId, word) VALUES
(1, 3, ARRAY[
    'Or', 'Un', 'Le', 'La', 'De', 'Et', 'Il', 'Je', 'Tu', 'Ne',
    'Eau', 'Ami', 'Mer', 'Bus', 'Vie', 'Riz', 'Bol', 'Sac', 'Feu', 'Air',
    'Ciel', 'Chat', 'Pain', 'Lune', 'Vert', 'Bleu', 'Sole', 'Vent', 'Nuit', 'Jour',
    'Main', 'Pied', 'Tete', 'Oeil', 'Bras', 'Bois', 'Pont', 'Gare', 'Rivi', 'Fleur',
    'Porte', 'Livre', 'Table', 'Petit', 'Grand', 'Rouge', 'Jaune', 'Blanc', 'Noire', 'Temps'
]),
(2, 3, ARRAY[
    'Pomme', 'Chien', 'Arbre', 'Route', 'Ville', 'Monde', 'Terre', 'Femme', 'Homme', 'Enfant',
    'Ecole', 'Classe', 'Papier', 'Stylos', 'Cahier', 'Musique', 'Soleil', 'Jardin', 'Oiseau', 'Bateau',
    'Maison', 'Chambre', 'Cuisine', 'Fentre', 'Chaise', 'Manger', 'Boire', 'Dormir', 'Parler', 'Regarder',
    'Simple', 'Rapide', 'Fort', 'Jeune', 'Vieux', 'Heureux', 'Triste', 'Froid', 'Chaud', 'Claire',
    'Lettre', 'Image', 'Nombre', 'Forme', 'Couleur', 'Travail', 'Argent', 'Heure', 'Minute', 'Seconde'
]),
(3, 3, ARRAY[
    'Voyage', 'Journal', 'Cuisine', 'Etudiant', 'Travail', 'Musique', 'Soleil', 'Pomme', 'Riviere', 'Montagne',
    'Histoire', 'Exemple', 'Village', 'Pensée', 'Science', 'Chambre', 'Sujet', 'Officier', 'Demain', 'Ensemble',
    'Batiment', 'Ordinateur', 'Distance', 'Peinture', 'Mouvement', 'Chocolat', 'Condition', 'Direction', 'Education', 'Attention',
    'Vacances', 'Cadeau', 'Famille', 'Mariage', 'Enfance', 'Voisin', 'Magasin', 'Journal', 'Billet', 'Eglise',
    'Hopital', 'Langue', 'Question', 'Standard', 'Culture', 'Espace', 'Public', 'Privé', 'Esprit', 'Corps'
]),
(4, 3, ARRAY[
    'Celebration', 'Experience', 'Information', 'Different', 'Decouverte', 'Important', 'Connaissance', 'Management', 'Opportunite', 'Performance',
    'Production', 'Technologie', 'Universite', 'Magnifique', 'Challenge', 'Caractere', 'Communaute', 'Decision', 'Determiner', 'Difficile',
    'Economie', 'Efficace', 'Equipement', 'Evidence', 'Exercice', 'Financier', 'Suivant', 'Bonheur', 'Influence', 'Inventaire',
    'Marketing', 'Mecanisme', 'Necessaire', 'Objectif', 'Passager', 'Politique', 'Potentiel', 'Presence', 'Pression', 'Principe',
    'Priorite', 'Procedure', 'Professeur', 'Propriete', 'Religieux', 'Solution', 'Specifique', 'Analyse', 'Strategie', 'Contexte'
]),
(5, 3, ARRAY[
    'Malheureusement', 'Gouvernemental', 'Environnement', 'Etablissement', 'Developpement', 'Individuellement', 'Particulierement', 'Professionnel', 'Communication', 'Administration',
    'Bibliotheque', 'Television', 'Telephone', 'Difference', 'Important', 'Maintenant', 'Aujourdhui', 'Restaurant', 'Spectacle', 'Ordinateur',
    'Information', 'Technologie', 'Education', 'Experience', 'Connaissance', 'Generation', 'Universite', 'Litterature', 'Philosophie', 'Psychologie',
    'Scientifique', 'Democratique', 'Economique', 'Politique', 'Historique', 'Geographique', 'Mathematique', 'Physique', 'Biologie', 'Chimie',
    'Traditionnel', 'Culturel', 'Artistique', 'Religieux', 'Socialiste', 'Libertaire', 'Revolution', 'Independance', 'Territoire', 'Population'
]);

INSERT INTO levels (levelId, length, content, mistakes) VALUES
(1, 249, 'aaaa ssss dddd ffff jjjj kkkk llll öööö asdf jklö fads jalk asdf jköl asds jklj fdsa ölkj adds kkll asaf jökö faff jölö daas kökö sasa lölö dfas jköl fall fass lass fass daff jojo dada ölöl asdf jklö falk kalf sala lads ölsf asjö dfjk asöf asdf jklö', 10),

(2, 234, 'asdfg hjklö gfdsa ölkjh fghj ghgh fada hjöl asghj ölkfg asdfg hjklö gashj fkdöl lksag hjfdg asdfg hjklö gashj fkdöl lksag hjfdg ggg hhh ghgh hghg asdfg hjklö asdfg hjklö gfdsa ölkjh asdfg hjklö gfdsa ölkjh ghgh ghgh asdfg hjklö', 10),

(3, 241, 'qqqq wwww eeee rrrr tttt qwert trew qwert werta qwert asert qwert qwert qwert qatert qwert qwert qwert qwert qwert qwert qwert qwert qwert qwert qwert qwert trewq trewq trewq trewq trewq qwert trewq qwert trewq qwert trewq qwerttrewq qwert', 8),

(4, 239, 'uuuu iiii oooo pppp zzzz uzio puzio oizup puzi uzio uiop zuiop puzio oizup uzio puzi uioo zzzz iiii oooo puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio puzio', 8),

(5, 229, 'yyyy xxxx cccc vvvv bbbb nnnn mmmm yxcv bnm yxcvb vbnm mnbv bcxy cvbn nbvc yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm yxcv bnm', 6),

(6, 239, 'aqay swsx dedc frfv gtgb jhjn jkjm lkl, ölö. aqsw ééé ààà èèè defr gtjh jklö yxcv bnmq éàè wert uiop asdf jklö yxcv bnmq wert uiop asdf jklö éé àà èè yxcv bnmq wert uiop asdf jklö yxcv bnmq éàè wert uiop asdf jklö yxcv bnmq wert uiop asdf jklö', 6),

(7, 247, 'Aaas Sssd Dddf Fffg Jjjh Kkkj Lllk Öööl ASDF JKLÖ aSdf jKlÖ ÉéÀà Èè AaSs DdFf JjKk LlÖö ASdf JKlö aSDF jKLÖ ÉÀÈ AaSs DdFf JjKk LlÖö ASdf JKlö aSDF jKLÖ ÉéÀà Èè AaSs DdFf JjKk LlÖö ASdf JKlö aSDF jKLÖ AaSs DdFf JjKk LlÖö ASdf JKlö aSDF jKLÖ', 4),

(8, 209, '1111 2222 3333 4444 5555 6666 7777 8888 9999 0000 1234 5678 9012 3456 7890 1q2w 3e4r 5t6z 7u8i 9o0p 1a2s 3d4f 5g6h 7j8k 9l0ö 1y2x 3c4v 5b6n 7m8, 9.0- 1234 5678 9012 3456 7890 1234 5678 9012 3456 7890', 4),

(9, 199, '!!!! ???? #### ++++ ---- **** //// ==== (((( )))) !!!! ???? #### ++++ ---- **** //// ==== (((( )))) !!!! ???? #### ++++ ---- **** //// ==== (((( )))) !!!! ???? #### ++++ ---- **** //// ==== (((( ))))', 2),

(10, 239, 'aS1! dF2" gH3# jK4$ lÖ5% qW6& eR7/ zU8( iO9) pP0= yX-_ cV+* bN:; mL<> aS1! dF2" gH3# jK4$ lÖ5% qW6& eR7/ zU8( iO9) pP0= yX-_ cV+* bN:; mL<> aS1! dF2" gH3# jK4$ lÖ5% qW6& eR7/ zU8( iO9) pP0= yX-_ cV+* bN:; mL<>', 1);
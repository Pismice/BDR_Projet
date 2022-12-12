DROP SCHEMA IF EXISTS valorant_tournament CASCADE;

CREATE SCHEMA valorant_tournament;

DROP TYPE IF EXISTS AGENT_TYPE CASCADE;
CREATE TYPE AGENT_TYPE AS ENUM('Controlleur','Duelliste','Initiateur','Sentinelle');

DROP TYPE IF EXISTS REGION CASCADE;
CREATE TYPE REGION AS ENUM('EMEA','AMERICAS','PACIFIC');

DROP TYPE IF EXISTS GAME_FORMAT CASCADE;
CREATE TYPE GAME_FORMAT AS ENUM ('bo1','bo3','bo5');

DROP TABLE IF EXISTS Pays CASCADE;
CREATE TABLE Pays(
	id SMALLSERIAL,
	nom VARCHAR(25) not null,
	CONSTRAINT PK_Pays PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Agent CASCADE;
CREATE TABLE Agent(
	id SMALLSERIAL,
	nom varchar(20) not null,
	role AGENT_TYPE not null,
	CONSTRAINT PK_Agent PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Carte CASCADE;
CREATE TABLE Carte(
	id SMALLSERIAL,
	nom varchar(20) not null,
	CONSTRAINT PK_Carte PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Joueur CASCADE;
CREATE TABLE Joueur(
	id SMALLSERIAL,
	nom varchar(20) not null,
	prenom varchar(20) not null,
	pseudonmye varchar(20) not null,
	age INTEGER not null,
	salaire DECIMAL not NULL,
	idPays INTEGER not null,
	CONSTRAINT PK_Joueur PRIMARY KEY (id),
	CONSTRAINT FK_Joueur_idPays FOREIGN KEY (idPays) REFERENCES Pays(id)
);

DROP TABLE IF EXISTS Equipe CASCADE;
CREATE TABLE Equipe(
	id SMALLSERIAL,
	nom VARCHAR(20),
	elo INTEGER,
	region REGION,
	CONSTRAINT PK_Equipe PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Joueur_Equipe CASCADE;
CREATE TABLE Joueur_Equipe(
	idJoueur INTEGER NOT NULL,
	idEquipe INTEGER NOT NULL,
	CONSTRAINT FK_Joueur_Equipe_idJoueur FOREIGN KEY (idJoueur) REFERENCES Joueur(id),
	CONSTRAINT FK_Joueur_Equipe_idEquipe FOREIGN KEY (idEquipe) REFERENCES Equipe(id)
);

DROP TABLE IF EXISTS Tournoi CASCADE;
CREATE TABLE Tournoi(
	id SMALLSERIAL,
	nom VARCHAR(20),
	cashprize DECIMAL,
	point INTEGER,
	dateDebut DATE,
	dateFin DATE,
	CONSTRAINT PK_Tournoi PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Tournoi_Equipe CASCADE;
CREATE TABLE Tournoi_Equipe(
	idTournoi INTEGER NOT NULL,
	idEquipe INTEGER NOT NULL,
	CONSTRAINT FK_Tournoi_Equipe_idTournoi FOREIGN KEY (idTournoi) REFERENCES Tournoi(id),
	CONSTRAINT FK_Tournoi_Equipe_idEquipe FOREIGN KEY (idEquipe) REFERENCES Equipe(id)
);

DROP TABLE IF EXISTS Match CASCADE;
CREATE TABLE Match(
	idTournoi INTEGER NOT NULL,
	noMatch SMALLSERIAL,
	game_format GAME_FORMAT,
	game_date DATE,
	CONSTRAINT FK_Match_idTournoi FOREIGN KEY (idTournoi) REFERENCES Tournoi(id),
	CONSTRAINT PK_Match PRIMARY KEY (idTournoi,noMatch)
);

DROP TABLE IF EXISTS Manche CASCADE;
CREATE TABLE Manche(
	idTournoi INTEGER NOT NULL,
	noMatch INTEGER NOT NULL,
	noManche SMALLSERIAL,
	noCarte INTEGER NOT NULL,
	CONSTRAINT PK_Manche PRIMARY KEY(idTournoi,noMatch,noManche),
	CONSTRAINT FK_Manche_idTournoi_noMatch FOREIGN KEY (idTournoi,noMatch) REFERENCES Match(idTournoi,noMatch),
	CONSTRAINT FK_Manche_idCarte FOREIGN KEY (noCarte) REFERENCES Carte(id)
);

DROP TABLE IF EXISTS Round CASCADE;
CREATE TABLE Round(
	idTournoi INTEGER NOT NULL,
	noMatch INTEGER NOT NULL,
	noManche INTEGER NOT NULL,
	noRound SMALLSERIAL,
	CONSTRAINT PK_Round PRIMARY KEY (idTournoi,noMatch,noManche,noRound),
	CONSTRAINT FK_Round_idTournoi_noMatch_noManche FOREIGN KEY (idTournoi,noMatch,noManche) REFERENCES Manche(idTournoi,noMatch,noManche)
);

DROP TABLE IF EXISTS Arme CASCADE;
CREATE TABLE Arme(
	id SMALLSERIAL,
	nom VARCHAR(20),
	CONSTRAINT PK_Arme PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Kill CASCADE;
CREATE TABLE Kill(
	idTournoi INTEGER NOT NULL,
	noMatch INTEGER NOT NULL,
	noManche INTEGER NOT NULL,
	noRound INTEGER NOT NULL,
	noKill SMALLSERIAL,
	idArme INTEGER NOT NULL,
	CONSTRAINT PK_Kill PRIMARY KEY (idTournoi,noMatch,noManche,noRound,noKill),
	CONSTRAINT FK_Kill_idTournoi_noMatch_noManche_noRound FOREIGN KEY (idTournoi,noMatch,noManche,noRound) REFERENCES Round(idTournoi,noMatch,noManche,noRound),
	CONSTRAINT FK_Kill_idArme FOREIGN KEY (idArme) REFERENCES Arme(id)
);

DROP TABLE IF EXISTS Joueur_Agent_Manche CASCADE;
CREATE TABLE Joueur_Agent_Manche(
	idJoueur INTEGER NOT NULL,
	idTournoi INTEGER NOT NULL,
	noMatch INTEGER NOT NULL,
	noManche INTEGER NOT NULL,
	idAgent INTEGER NOT NULL,
	CONSTRAINT FK_Joueur_Agent_Manche_idJoueur FOREIGN KEY (idJoueur) REFERENCES Joueur(id),
	CONSTRAINT FK_Joueur_Agent_Manche_idAgent FOREIGN KEY (idAgent) REFERENCES Agent(id),
	CONSTRAINT FK_Joueur_Agent_Manche_noManche FOREIGN KEY (idTournoi,noMatch,noManche) REFERENCES Manche(idTournoi,noMatch,noManche),
	CONSTRAINT PK_Joueur_Agent_Manche PRIMARY KEY (idJoueur,idTournoi,noMatch,noManche)
);
DROP SCHEMA IF EXISTS valorant_tournament;

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
	CONSTRAINTS PK_Pays PRIMARY KEY(id)
);

DROP TABLE IF EXISTS Agent CASCADE;
CREATE TABLE Agent(
	id SMALLSERIAL,
	nom varchar(20) not null,
	role AGENT_TYPE not null,
	CONSTRAINTS PK_Agent PRIMARY KEY(id)
);

DROP TABLE IF EXISTS Carte CASCADE;
CREATE TABLE Carte(
	id SMALLSERIAL,
	nom varchar(20) not null,
	CONSTRAINTS PK_Carte PRIMARY KEY(id)
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
	CONSTRAINTS PK_Joueur PRIMARY KEY(id),
	CONSTRAINTS FK_Joueur_idPays FOREIGN KEY (idPays) REFERENCES Pays(id)
);

DROP TABLE IF EXISTS Equipe CASCADE;
CREATE TABLE Equipe(
	id SMALLSERIAL,
	nom VARCHAR(20),
	elo INTEGER,
	region REGION,
	CONSTRAINTS PK_Equipe PRIMARY KEY(id)
);

DROP TABLE IF EXISTS Joueur_Equipe CASCADE;
CREATE TABLE Joueur_Equipe(
	idJoueur INTEGER NOT NULL,
	idEquipe INTEGER NOT NULL,
	CONSTRAINTS FK_Joueur_Equipe_idJoueur FOREIGN KEY(idJoueur) REFERENCES Joueur(id),
	CONSTRAINTS FK_Joueur_Equipe_idEquipe FOREIGN KEY(idEquipe) REFERENCES Equipe(id)
);

DROP TABLE IF EXISTS Tournoi CASCADE;
CREATE TABLE Tournoi(
	id SMALLSERIAL,
	nom VARCHAR(20),
	cashprize DECIMAL,
	point INTEGER,
	dateDebut DATE,
	dateFin DATE,
	CONSTRAINTS PK_Tournoi PRIMARY KEY(id)
);

DROP TABLE IF EXISTS Tournoi_Equipe CASCADE;
CREATE TABLE Tournoi_Equipe(
	idTournoi INTEGER NOT NULL,
	idEquipe INTEGER NOT NULL,
	CONSTRAINTS FK_Tournoi_Equipe_idTournoi FOREIGN KEY(idTournoi) REFERENCES Tournoi(id),
	CONSTRAINTS FK_Tournoi_Equipe_idEquipe FOREIGN KEY(idEquipe) REFERENCES Equipe(id)
);

DROP TABLE IF EXISTS Match CASCADE;
CREATE TABLE Match(
	idTournoi INTEGER NOT NULL,
	game_format GAME_FORMAT,
	game_date DATE,
	CONSTRAINTS FK_Match_idTournoi FOREIGN KEY(idTournoi) REFERENCES Tournoi(id)
);
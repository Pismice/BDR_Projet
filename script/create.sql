DROP TYPE IF EXISTS AGENT_TYPE CASCADE;
CREATE TYPE AGENT_TYPE AS ENUM('Controlleur','Duelliste','Initiateur','Sentinelle');

DROP TYPE IF EXISTS REGION CASCADE;
CREATE TYPE REGION AS ENUM('EMEA','AMERICAS','PACIFIC');

DROP TYPE IF EXISTS GAME_FORMAT CASCADE;
CREATE TYPE GAME_FORMAT AS ENUM ('bo1','bo3','bo5');

DROP DOMAIN IF EXISTS NAME_FORMAT CASCADE;
CREATE DOMAIN NAME_FORMAT VARCHAR(20) NOT NULL;

DROP TABLE IF EXISTS Pays CASCADE;
CREATE TABLE Pays(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	CONSTRAINT PK_Pays PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Agent CASCADE;
CREATE TABLE Agent(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	role AGENT_TYPE not null,
	CONSTRAINT PK_Agent PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Carte CASCADE;
CREATE TABLE Carte(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	CONSTRAINT PK_Carte PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Equipe CASCADE;
CREATE TABLE Equipe(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	elo SMALLINT,
	region REGION,
	CONSTRAINT PK_Equipe PRIMARY KEY (id),
	CONSTRAINT elo_check CHECK (elo > 0)
);

DROP TABLE IF EXISTS Joueur CASCADE;
CREATE TABLE Joueur(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	prenom NAME_FORMAT,
	pseudonyme NAME_FORMAT,
	dateNaissance DATE not null ,
	salaire SMALLINT not NULL,
	idPays SMALLINT not null,
	idEquipe SMALLINT,
	CONSTRAINT PK_Joueur PRIMARY KEY (id),
	CONSTRAINT FK_Joueur_idPays FOREIGN KEY (idPays) REFERENCES Pays(id) ON DELETE CASCADE,
	CONSTRAINT FK_Joueur_idEquipe FOREIGN KEY (idEquipe) REFERENCES Equipe(id) ON DELETE CASCADE,
	CONSTRAINT salaire_check CHECK (salaire > 0)
);

DROP TABLE IF EXISTS Tournoi CASCADE;
CREATE TABLE Tournoi(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	cashprize SMALLINT,
	point SMALLINT,
	dateDebut DATE,
	dateFin DATE,
	CONSTRAINT PK_Tournoi PRIMARY KEY (id),
	CONSTRAINT cashprize_check CHECK(cashprize > 0 AND cashprize % 8 = 0),
	CONSTRAINT point_check CHECK(point > 0 AND point % 8 = 0)
);

DROP TABLE IF EXISTS Tournoi_Equipe CASCADE;
CREATE TABLE Tournoi_Equipe(
	idTournoi SMALLINT NOT NULL,
	idEquipe SMALLINT NOT NULL,
	CONSTRAINT FK_Tournoi_Equipe_idTournoi FOREIGN KEY (idTournoi) REFERENCES Tournoi(id) ON DELETE CASCADE,
	CONSTRAINT FK_Tournoi_Equipe_idEquipe FOREIGN KEY (idEquipe) REFERENCES Equipe(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Match CASCADE;
CREATE TABLE Match(
	idTournoi SMALLINT NOT NULL,
	noMatch SMALLSERIAL,
	gameFormat GAME_FORMAT,
	gameDate DATE,
	noMatchSuivant SMALLINT,
	idEquipeGauche SMALLINT,
	idEquipeDroite SMALLINT,
	CONSTRAINT PK_Match PRIMARY KEY (idTournoi,noMatch),
	CONSTRAINT FK_Match_idTournoi FOREIGN KEY (idTournoi) REFERENCES Tournoi(id) ON DELETE CASCADE,
	CONSTRAINT FK_Match_noMatchSuivant FOREIGN KEY (idTournoi,noMatchSuivant) REFERENCES Match(idTournoi,noMatch) ON DELETE CASCADE,
	CONSTRAINT nomatchsuivant_check CHECK (noMatchSuivant <> noMatch)
);

DROP TABLE IF EXISTS Manche CASCADE;
CREATE TABLE Manche(
	idTournoi SMALLINT NOT NULL,
	noMatch SMALLINT NOT NULL,
	noManche SMALLSERIAL,
	noCarte SMALLINT NOT NULL,
	CONSTRAINT PK_Manche PRIMARY KEY(idTournoi,noMatch,noManche),
	CONSTRAINT FK_Manche_idTournoi_noMatch FOREIGN KEY (idTournoi,noMatch) REFERENCES Match(idTournoi,noMatch) ON DELETE CASCADE,
	CONSTRAINT FK_Manche_idCarte FOREIGN KEY (noCarte) REFERENCES Carte(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Round CASCADE;
CREATE TABLE Round(
	idTournoi SMALLINT NOT NULL,
	noMatch SMALLINT NOT NULL,
	noManche SMALLINT NOT NULL,
	noRound SMALLSERIAL,
	CONSTRAINT PK_Round PRIMARY KEY (idTournoi,noMatch,noManche,noRound),
	CONSTRAINT FK_Round_idTournoi_noMatch_noManche FOREIGN KEY (idTournoi,noMatch,noManche) REFERENCES Manche(idTournoi,noMatch,noManche) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Arme CASCADE;
CREATE TABLE Arme(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	CONSTRAINT PK_Arme PRIMARY KEY (id)
);

DROP TABLE IF EXISTS Kill CASCADE;
CREATE TABLE Kill(
	idTournoi SMALLINT NOT NULL,
	noMatch SMALLINT NOT NULL,
	noManche SMALLINT NOT NULL,
	noRound SMALLINT NOT NULL,
	noKill SMALLSERIAL,
	idTueur SMALLINT NOT NULL,
	idMort SMALLINT NOT NULL,
	idArme SMALLINT NOT NULL,
	CONSTRAINT PK_Kill PRIMARY KEY (idTournoi,noMatch,noManche,noRound,noKill),
	CONSTRAINT FK_Kill_idTournoi_noMatch_noManche_noRound FOREIGN KEY (idTournoi,noMatch,noManche,noRound) REFERENCES Round(idTournoi,noMatch,noManche,noRound) ON DELETE CASCADE,
	CONSTRAINT FK_Kill_idArme FOREIGN KEY (idArme) REFERENCES Arme(id) ON DELETE CASCADE,
	CONSTRAINT FK_Kill_idTueur FOREIGN KEY (idTueur) REFERENCES Joueur(id) ON DELETE CASCADE,
	CONSTRAINT FK_Kill_idMort FOREIGN KEY (idMort) REFERENCES Joueur(id) ON DELETE CASCADE,
	CONSTRAINT idtueur_idmort_check CHECK(idTueur <> idMort)
);

DROP TABLE IF EXISTS Joueur_Agent_Manche CASCADE;
CREATE TABLE Joueur_Agent_Manche(
	idJoueur SMALLINT NOT NULL,
	idTournoi SMALLINT NOT NULL,
	noMatch SMALLINT NOT NULL,
	noManche SMALLINT NOT NULL,
	idAgent SMALLINT NOT NULL,
	CONSTRAINT FK_Joueur_Agent_Manche_idJoueur FOREIGN KEY (idJoueur) REFERENCES Joueur(id) ON DELETE CASCADE,
	CONSTRAINT FK_Joueur_Agent_Manche_idAgent FOREIGN KEY (idAgent) REFERENCES Agent(id) ON DELETE CASCADE,
	CONSTRAINT FK_Joueur_Agent_Manche_noManche FOREIGN KEY (idTournoi,noMatch,noManche) REFERENCES Manche(idTournoi,noMatch,noManche) ON DELETE CASCADE,
	CONSTRAINT PK_Joueur_Agent_Manche PRIMARY KEY (idJoueur,idTournoi,noMatch,noManche,idAgent)
);

DROP VIEW IF EXISTS vEquipeActive;
CREATE VIEW vEquipeActive AS 
SELECT equipe.* FROM equipe 
INNER JOIN joueur ON equipe.id = joueur.idEquipe
GROUP BY equipe.id
HAVING count(joueur.id) = 5;

CREATE OR REPLACE FUNCTION checkManche() RETURNS TRIGGER AS 
$BODY$
LANGUAGE plpgsql
DECLARE 
	bo integer;
	count integer;
	gameFormat GAME_FORMAT;
BEGIN
	SELECT gameFormat FROM Match
	WHERE (idTournoi,noMatch) = (NEW.idTournoi, NEW.noMatch)
	INTO gameFormat;
	CASE 
		WHEN gameFormat = bo1 THEN bo = 1
		WHEN gameFormat = bo3 THEN bo = 3
		WHEN gameFormat = bo5 THEN bo = 5
	END;
	SELECT COUNT(noManche) FROM Manche
	WHERE (idTournoi,noMatch) = (NEW.idTournoi, NEW.noMatch)
	INTO count;
	IF (count > bo) THEN 
		raise exception 'Il y a trop de manche pour ce match!';
	END IF;
	RETURN NEW;
END;

CREATE TRIGGER addManche AFTER INSERT OF Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkManche();
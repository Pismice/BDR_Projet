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
	idCarte SMALLINT NOT NULL,
	CONSTRAINT PK_Manche PRIMARY KEY(idTournoi,noMatch,noManche),
	CONSTRAINT FK_Manche_idTournoi_noMatch FOREIGN KEY (idTournoi,noMatch) REFERENCES Match(idTournoi,noMatch) ON DELETE CASCADE,
	CONSTRAINT FK_Manche_idCarte FOREIGN KEY (idCarte) REFERENCES Carte(id) ON DELETE CASCADE
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

DROP VIEW IF EXISTS vRoundFini;
CREATE VIEW vRoundFini AS
SELECT round.idTournoi idTournoi, round.noMatch noMatch, round.noManche noManche, equipe.id idVainqueur
FROM round 
INNER JOIN match on (match.idTournoi,match.noMatch) = (round.idTournoi, round.noMatch)
INNER JOIN kill on (round.idTournoi, round.noMatch, round.noManche, round.noRound) = (kill.idTournoi, kill.noMatch, kill.noManche, kill.noRound)
INNER JOIN joueur on kill.idTueur = joueur.id
INNER JOIN equipe on joueur.idEquipe = equipe.id
WHERE match.idEquipeGauche = equipe.id or match.idEquipeDroite = equipe.id
GROUP BY round.idtournoi, round.nomatch, round.nomanche, equipe.id
HAVING count(kill.idMort) = 5;



DROP VIEW IF EXISTS vMancheFini;
CREATE VIEW vMancheFini AS
SELECT idTournoi, noMatch, noManche, idEquipe idVainqueur
FROM Manche;

DROP VIEW IF EXISTS vMatchFini;
CREATE VIEW vMatchFini AS
SELECT * FROM Match;


CREATE OR REPLACE FUNCTION checkNumberManche() RETURNS TRIGGER AS 
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
		ROLLBACK;
	END IF;
	RETURN NULL;
END;

CREATE OR REPLACE FUNCTION checkSameCarte() RETURNS VOID
AS $BODY$
LANGUAGE plpgsql;
DECLARE 
	count integer;
BEGIN 
	SELECT count(noManche) FROM manche
	WHERE (idTournoi, noMatch) = (new.idTournoi, new.noMatch) AND idCarte = new.idCarte
	INTO count;
	if(count > 1) then 
		ROLLBACK;
	END IF;
	RETURN NULL;
END;
$BODY$

CREATE OR REPLACE FUNCTION triggersAfterManche() RETURNS VOID 
AS $BODY$
LANGUAGE plpgsql;
BEGIN
	PERFORM checkNumberManche();
	PERFORM checkSameCarte();
END;
$BODY$


CREATE OR REPLACE TRIGGER afterInsertManche AFTER INSERT OF Manche 
FOR EACH ROW
EXECUTE PROCEDURE triggersAfterManche();

CREATE OR REPLACE FUNCTION checkMatchDate() RETURNS TRIGGER AS
$BODY$
DECLARE 
	dateDebut DATE;
	dateFin DATE;
LANGUAGE plpgsql;
BEGIN
	SELECT dateDebut, dateFin FROM Tournoi
	WHERE idTournoi = NEW.idTournoi
	INTO (dateDebut,dateFin);
	IF NOT (NEW.gamedate BETWEEN dateDebut and dateFin)
		THEN ROLLBACK;
	ELSE 

	END IF;
	RETURN NULL;
END;

CREATE OR REPLACE FUNCTION triggersAfterMatch() RETURNS VOID 
AS $BODY$
LANGUAGE plpgsql;
BEGIN
	PERFORM checkMatchDate();

END;
$BODY$

CREATE OR REPLACE TRIGGER beforeInsertMatch AFTER INSERT OF match
FOR EACH ROW
EXECUTE PROCEDURE triggersAfterMatch();


CREATE OR REPLACE FUNCTION checkKillSameTeam() RETURNS TRIGGER AS
$BODY$
LANGUAGE plpgsql;
BEGIN
	IF((SELECT idEquipe FROM joueur where id = new.idTueur) = (SELECT idEquipe FROM Joueur WHERE id = new.idMort)) THEN 
		raise exception 'Un joueur ne peux pas tuer un joueur de son équipe';
	END IF;
	RETURN NULL;
END;

CREATE OR REPLACE FUNCTION checkJoueurNotKilledTwice() RETURNS TRIGGER AS
$BODY$
LANGUAGE plpgsql;
DECLARE 
	count integer;
BEGIN
	SELECT count(idTueur) 
	FROM Kill 
	WHERE (idtournoi,nomatch,nomanche,noround) = (new.idtournoi, new.nomatch, new.nomanche, new.noround) AND idMort = new.idMort
	INTO count; 
	IF(count = 2) THEN 
		raise exception 'Le joueur a deja été tué!';
	END IF;
	RETURN NULL;
END;

CREATE OR REPLACE triggersAfterAddKill() RETURNS VOID
AS $BODY$
LANGUAGE plpgsql;
BEGIN
	PERFORM checkKillSameTeam();
	PERFORM checkJoueurNotKilledTwice();
END;
$BODY$

CREATE OR REPLACE TRIGGER afterAddKill AFTER INSERT OF Kill
FOR EACH ROW 
EXECUTE PROCEDURE triggersAfterAddKill();


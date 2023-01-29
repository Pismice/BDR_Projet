
DROP TYPE IF EXISTS AGENT_TYPE CASCADE;
CREATE TYPE AGENT_TYPE AS ENUM('Controlleur','Duelliste','Initiateur','Sentinelle');

DROP TYPE IF EXISTS REGION CASCADE;
CREATE TYPE REGION AS ENUM('EMEA','AMERICAS','PACIFIC');

DROP TYPE IF EXISTS GAME_FORMAT CASCADE;
CREATE TYPE GAME_FORMAT AS ENUM ('bo1','bo3','bo5');

DROP DOMAIN IF EXISTS NAME_FORMAT CASCADE;
CREATE DOMAIN NAME_FORMAT VARCHAR(20) NOT NULL;
--table
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
	CONSTRAINT salaire_check CHECK (salaire >= 0)
);

DROP TABLE IF EXISTS Tournoi CASCADE;
CREATE TABLE Tournoi(
	id SMALLSERIAL,
	nom NAME_FORMAT,
	cashprize bigint,
	point bigint,
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
	CONSTRAINT PK_Joueur_Agent_Manche PRIMARY KEY (idJoueur,idTournoi,noMatch,noManche)
);
--Vue
DROP VIEW IF EXISTS vEquipeActive CASCADE;
CREATE VIEW vEquipeActive AS 
SELECT equipe.* FROM equipe 
INNER JOIN joueur ON equipe.id = joueur.idEquipe
GROUP BY equipe.id
HAVING count(joueur.id) = 5;

DROP VIEW IF EXISTS vRoundFini CASCADE;
CREATE VIEW vRoundFini AS
SELECT round.idTournoi idTournoi, round.noMatch noMatch, round.noManche noManche,round.noRound noRound, equipe.id idVainqueur
FROM round 
INNER JOIN match on (match.idTournoi,match.noMatch) = (round.idTournoi, round.noMatch)
INNER JOIN kill on (round.idTournoi, round.noMatch, round.noManche, round.noRound) = (kill.idTournoi, kill.noMatch, kill.noManche, kill.noRound)
INNER JOIN joueur on kill.idTueur = joueur.id
INNER JOIN equipe on joueur.idEquipe = equipe.id
GROUP BY round.idtournoi, round.nomatch, round.nomanche, round.noround, equipe.id
HAVING count(*) = 5;

DROP VIEW IF EXISTS vMancheFini CASCADE;
CREATE VIEW vMancheFini AS
SELECT manche.idTournoi, manche.noMatch, manche.noManche, vRoundFini.idVainqueur idVainqueur
FROM manche 
INNER JOIN match on (match.idTournoi,match.noMatch) = (manche.idTournoi, manche.noMatch)
INNER JOIN vRoundFini on (manche.idTournoi, manche.noMatch, manche.noManche) = (vRoundFini.idTournoi, vRoundFini.noMatch, vRoundFini.noManche)
GROUP BY manche.idTournoi, manche.noMatch, manche.noManche, vRoundFini.idVainqueur
HAVING count(*) = 13
ORDER BY manche.idTournoi, manche.noMatch, manche.noManche;

DROP VIEW IF EXISTS vMatchFini CASCADE;
CREATE VIEW vMatchFini AS
SELECT match.idTournoi, match.noMatch, vMancheFini.idVainqueur idVainqueur
FROM Match
INNER JOIN vMancheFini ON (match.idTournoi, match.noMatch) = (vMancheFini.idTournoi, vMancheFini.noMatch)
GROUP BY match.idTournoi, match.noMatch, vMancheFini.idVainqueur
HAVING count(*) = 
CASE
	WHEN match.gameFormat = 'bo1' THEN 1
	WHEN match.gameFormat = 'bo3' THEN 2
	WHEN match.gameFormat = 'bo5' THEN 3
END
ORDER BY match.idTournoi, match.noMatch;

DROP VIEW IF EXISTS vTournoiFini CASCADE;
CREATE VIEW vTournoiFini AS
SELECT tournoi.id, vMatchFini.idVainqueur idVainqueur
FROM tournoi
inner join match on tournoi.id = match.idtournoi
inner join vmatchfini on match.idtournoi = vmatchfini.idtournoi and match.nomatch = vmatchfini.nomatch
where nomatchsuivant is null
ORDER BY tournoi.id;
 

DROP VIEW IF EXISTS vJoueurStat CASCADE;
CREATE VIEW vJoueurStat AS 
SELECT joueur.id,joueur.nom,joueur.prenom,joueur.pseudonyme, 
    COALESCE(( SELECT count(kill.idmort) AS count
           FROM kill
          WHERE kill.idtueur = joueur.id
          GROUP BY kill.idtueur), 0::bigint) AS nombrekill,
    COALESCE(( SELECT count(kill.idtueur) AS count
           FROM kill
          WHERE kill.idmort = joueur.id
          GROUP BY kill.idmort), 0::bigint) AS nombremort,
    COALESCE(( SELECT count(*) AS count
           FROM joueur_agent_manche
          WHERE joueur_agent_manche.idjoueur = joueur.id
          GROUP BY joueur_agent_manche.idjoueur), 0::bigint) AS nombremanchejouer,
    COALESCE(( SELECT count(*) AS count
           FROM vmanchefini
          WHERE vmanchefini.idvainqueur = joueur.idequipe
          GROUP BY vmanchefini.idvainqueur), 0::bigint) AS nombremanchegagnee
   FROM joueur;

DROP VIEW IF EXISTS vJoueurAgent CASCADE;
CREATE VIEW vJoueurAgent AS
SELECT joueur.id as idJoueur, agent.id as idAgent, agent.nom agentNom, count(Joueur_Agent_Manche.noManche) nombreFoisJouer
FROM joueur
LEFT JOIN Joueur_Agent_Manche on joueur.id = Joueur_Agent_Manche.idJoueur
CROSS JOIN Agent 
GROUP BY Agent.id,Joueur.id;

DROP VIEW IF EXISTS vEquipeStat CASCADE;
CREATE VIEW vEquipeStat AS 
SELECT equipe.id, equipe.nom, 
(SELECT Count(Distinct idtournoi) FROM tournoi_equipe where idequipe = equipe.id) as nombreTournoiJouer,
(SELECT Count(Distinct (idtournoi,nomatch)) FROM match where idequipegauche = equipe.id or idequipedroite = equipe.id) as nombreMatchJouer,
(SELECT COUNT(DISTINCT (idtournoi,nomatch)) FROM vmatchfini where idvainqueur = equipe.id) as nombreMatchGagnee
FROM equipe
LEFT JOIN Tournoi_Equipe on Tournoi_Equipe.idEquipe = equipe.id
LEFT JOIN match on (match.idEquipeGauche = equipe.id or match.idEquipeDroite = equipe.id)
LEFT JOIN vMatchFini on vMatchFini.idVainqueur = equipe.id
GROUP BY equipe.id;

DROP VIEW IF EXISTS vArmeStat CASCADE;
CREATE VIEW vArmeStat AS
SELECT arme.*, count(nokill) nombreKills
FROM arme 
LEFT JOIN kill on arme.id = kill.idArme
group by arme.id;

DROP VIEW IF EXISTS vAgentStat CASCADE;
CREATE VIEW vAgentStat AS
SELECT agent.*,
count(DISTINCT (Joueur_Agent_Manche.idTournoi, Joueur_Agent_Manche.noMatch, Joueur_Agent_Manche.noManche, Joueur_Agent_Manche.idJoueur)) as nombreFoisJouer,
count(kill.idMort) as nombreDeKill
FROM agent 
INNER JOIN Joueur_Agent_Manche on agent.id = Joueur_Agent_Manche.idAgent
INNER JOIN Kill on (Joueur_Agent_Manche.idTournoi, Joueur_Agent_Manche.noMatch, Joueur_Agent_Manche.noManche, Joueur_Agent_Manche.idJoueur) = (Kill.idTournoi, Kill.noMatch, Kill.noManche, Kill.idTueur)
GROUP BY Agent.id;

DROP VIEW IF EXISTS vTournoiMatch CASCADE;
CREATE VIEW vTournoiMatch AS
SELECT m1.idtournoi, m1.nomatch, m1.idEquipeGauche, m1.idEquipeDroite,
CASE WHEN m1.idEquipeGauche IS NOT NULL 
THEN (SELECT equipe.nom FROM equipe WHERE id = m1.idEquipeGauche) 
ELSE CONCAT('Vainqueur #',(SELECT m2.nomatch from match m2 WHERE m2.noMatchSuivant = m1.nomatch GROUP BY m2.nomatch  HAVING m2.nomatch <= all(SELECT nomatch from match m3 where m3.noMatchSuivant = m1.nomatch)))
END AS nomEquipeGauche,
CASE WHEN m1.idEquipeDroite IS NOT NULL 
THEN (SELECT equipe.nom FROM equipe WHERE id = m1.idEquipeDroite) 
ELSE CONCAT('Vainqueur #',(SELECT m2.nomatch from match m2 WHERE m2.noMatchSuivant = m1.nomatch GROUP BY m2.nomatch HAVING m2.nomatch >= all(SELECT nomatch from match m3 where m3.noMatchSuivant = m1.nomatch)))
END AS nomEquipeDroite
FROM match m1 ORDER BY m1.idtournoi,m1.noMatch;

-- fonction triggers pour manche
CREATE OR REPLACE FUNCTION checkNumberManche() RETURNS TRIGGER AS 
$BODY$
DECLARE 
	bo SMALLINT;
	count SMALLINT;
	gameFormat match.gameformat%type;
BEGIN
	SELECT match.gameFormat FROM Match
	WHERE (idTournoi,noMatch) = (NEW.idTournoi, NEW.noMatch)
	INTO gameFormat;
	CASE 
		WHEN gameFormat = 'bo1' THEN bo = 1;
		WHEN gameFormat = 'bo3' THEN bo = 3;
		WHEN gameFormat = 'bo5' THEN bo = 5;
	END CASE;
	SELECT COUNT(manche.noManche) FROM Manche
	WHERE (idTournoi,noMatch) = (NEW.idTournoi, NEW.noMatch)
	INTO count;
	IF (count > bo) THEN 
		raise exception 'La totalité des manches de ce match on déjà été ajouté';
		ROLLBACK;	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkSameCarte() RETURNS TRIGGER
AS $BODY$

DECLARE 
	count_carte SMALLINT;
BEGIN 
	SELECT count(manche.noManche) FROM manche
	WHERE (idTournoi, noMatch) = (new.idTournoi, new.noMatch) AND idCarte = new.idCarte
	INTO count_carte;
	if(count_carte > 1) then 
		raise exception 'La carte a déjà été joué lors de ce match';
		ROLLBACK;	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tournoiFini(idT tournoi.id%type) returns void
AS $BODY$
DECLARE 
	point_total tournoi.point%type;
	nombre_participant smallint;

BEGIN 
	SELECT point FROM tournoi WHERE id = idt INTO point_total;
	SELECT COUNT(idequipe) from tournoi_equipe WHERE idtournoi = idt INTO nombre_participant;
	IF(nombre_participant < 4) 
	THEN 
		-- il y a donc que 2 équipes dans le tournoi
		UPDATE equipe set elo = elo + point_total where id = (select idvainqueur from vtournoifini where id = idt);
	ELSE
		-- il y a 4 ou + équipes dans le tournoi
		UPDATE equipe set elo = elo + point_total/2 where id = (select idvainqueur from vtournoifini where id = idt);
		WITH max_win as (
		select count(*) as val
			 from vmatchfini where idtournoi = idT 
			 group by idtournoi,idvainqueur 
			 having count(idvainqueur) >= 
			 all(
				 select count(*) 
				 from vmatchfini 
				 where idtournoi = idT
				 group by idtournoi,idvainqueur
		))
		UPDATE equipe set elo = elo + point_total/4 where id = (select idvainqueur from vmatchfini 
																where idtournoi = idT
																group by idtournoi,idvainqueur
																having count(*) = (select (val-1) from max_win));
																WITH max_win as (
		select count(*) as val
			 from vmatchfini where idtournoi = idT 
			 group by idtournoi,idvainqueur 
			 having count(idvainqueur) >= 
			 all(
				 select count(*) 
				 from vmatchfini 
				 where idtournoi = idT
				 group by idtournoi,idvainqueur
		))
		UPDATE equipe set elo = elo + point_total/8 where id in (select idvainqueur from vmatchfini 
																where idtournoi = idT
																group by idtournoi,idvainqueur
																having count(*) = (select (val-2) from max_win));

	END IF;
END; $BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION matchFini(idT match.idtournoi%type ,noM match.nomatch%type) returns void
AS $BODY$
DECLARE 
	nms match.noMatchSuivant%type;
	idVainqueur vmatchfini.idvainqueur%type;
BEGIN 
	SELECT match.nomatchsuivant FROM match WHERE match.idtournoi = idT and match.nomatch = noM INTO nms;
	SELECT vmatchfini.idvainqueur from vmatchfini where vmatchfini.idtournoi = idT and vmatchfini.nomatch = noM INTO idVainqueur;
	UPDATE match 
	SET
	idequipegauche =
	CASE 
		WHEN noM <=all(select nomatch FROM match where match.idtournoi = idT and match.nomatchsuivant = nms)
		THEN idvainqueur
		ELSE idequipegauche
	END,
	idequipedroite =
	CASE 
		WHEN noM >=all(select nomatch FROM match where match.idtournoi = idT and match.nomatchsuivant = nms)
		THEN idvainqueur 
		ELSE  idequipedroite
	END
	WHERE nomatch = nms;
	raise notice 'Le match suivant à été mis à jour';
	return;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkCanAddManche() RETURNS TRIGGER
AS $BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(*) FROM vmatchfini
	WHERE (vmatchfini.idtournoi,vmatchfini.nomatch) = (new.idtournoi,new.nomatch)
	INTO count; 
	IF(count > 0) THEN 
		raise exception 'Le match est fini, on ne peut pas ajouter de manche supplémentaire!';
		ROLLBACK;	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkNeedUpdateNextMatch() RETURNS TRIGGER
AS $BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(*) FROM vmatchfini
	WHERE (vmatchfini.idtournoi,vmatchfini.nomatch) = (new.idtournoi,new.nomatch)
	INTO count;
	IF(count > 0) THEN
		PERFORM matchFini(new.idtournoi,new.nomatch);
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


-- trigger de manche
CREATE OR REPLACE TRIGGER tgr_02_InsertManche BEFORE INSERT on Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkCanAddManche();
CREATE OR REPLACE TRIGGER tgr_03_InsertManche AFTER INSERT on Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkNumberManche();
CREATE OR REPLACE TRIGGER tgr_04_InsertManche AFTER INSERT on Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkSameCarte();

-- fonction trigger de match
CREATE OR REPLACE FUNCTION checkMatchDate() RETURNS TRIGGER AS
$BODY$
DECLARE 
	dateDebut tournoi.datedebut%type;
	dateFin tournoi.datefin%type;

BEGIN
	SELECT tournoi.dateDebut, tournoi.dateFin FROM Tournoi
	WHERE tournoi.id = NEW.idTournoi
	INTO dateDebut,dateFin;
	IF NOT (NEW.gamedate BETWEEN dateDebut and dateFin)
		THEN raise exception 'La date du match ne se trouve pas dans les dates du tournoi';
		ROLLBACK;
	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;
--change to checkcanaddmatch utiliser tournoifini
CREATE OR REPLACE FUNCTION checkCanAddMatch() RETURNS TRIGGER
AS $BODY$

DECLARE 
	count SMALLINT;
BEGIN 
	SELECT COUNT(idTueur) FROM kill 
	WHERE kill.idTournoi = NEW.idtournoi
	GROUP BY kill.idTournoi
	INTO count;
	IF(count > 0) THEN 
		raise exception 'Le tournoi a déjà commencé on ne peut pas rajouter de match!';
		ROLLBACK;	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de match
CREATE OR REPLACE TRIGGER tgr_01_InsertMatch BEFORE INSERT on match
FOR EACH ROW
EXECUTE PROCEDURE checkCanAddMatch();
CREATE OR REPLACE TRIGGER tgr_02_InsertMatch AFTER INSERT on match
FOR EACH ROW
EXECUTE PROCEDURE checkMatchDate();

-- fonction trigger de kill
CREATE OR REPLACE FUNCTION checkKillSameTeam() RETURNS TRIGGER AS
$BODY$
BEGIN
	IF((SELECT idEquipe FROM joueur where id = new.idTueur) = (SELECT idEquipe FROM Joueur WHERE id = new.idMort)) THEN 
		raise exception 'Un joueur ne peux pas tuer un joueur de son équipe';
		ROLLBACK;
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkJoueurNotKilledTwice() RETURNS TRIGGER AS
$BODY$

DECLARE 
	count SMALLINT;
BEGIN
	SELECT count(idTueur) 
	FROM Kill 
	WHERE (idtournoi,nomatch,nomanche,noround) = (new.idtournoi, new.nomatch, new.nomanche, new.noround) AND idMort = new.idMort
	INTO count; 
	IF(count = 2) THEN 
		raise exception 'Le joueur a deja été tué!';
		ROLLBACK;
	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkCanAddRound() RETURNS TRIGGER AS 
$BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(*) FROM vMancheFini
	WHERE (vMancheFini.idtournoi,vMancheFini.nomatch,vMancheFini.nomanche) = (new.idtournoi,new.nomatch,new.nomanche)
	INTO count;
	IF(count > 0) THEN 
		raise exception 'La manche est fini, on ne peut pas ajouter de round supplémentaire!';
		ROLLBACK;	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkCanAddKill() RETURNS TRIGGER AS 
$BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(*) from vRoundFini
	WHERE (vRoundFini.idTournoi,vRoundFini.noMatch,vRoundFini.nomanche,vRoundFini.noround) = (new.idTournoi,new.noMatch,new.nomanche,new.noround)
	INTO count;
	if(count > 0) 
	THEN
		raise exception 'Le round est fini, on ne peut pas ajouter de kill supplémentaire!';
		ROLLBACK;	
	end if;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de kill
CREATE OR REPLACE TRIGGER tgr_01_AfterAddKill BEFORE INSERT on Kill
FOR EACH ROW 
EXECUTE PROCEDURE checkCanAddKill();
CREATE OR REPLACE TRIGGER tgr_02_AfterAddKill AFTER INSERT on Kill
FOR EACH ROW 
EXECUTE PROCEDURE checkKillSameTeam();
CREATE OR REPLACE TRIGGER tgr_03_AfterAddKill AFTER INSERT on Kill
FOR EACH ROW 
EXECUTE PROCEDURE checkJoueurNotKilledTwice();

--fonction trigger de round

--trigger de round
CREATE OR REPLACE TRIGGER tgr_01_BeforeAddRound BEFORE INSERT on round
FOR EACH ROW
EXECUTE PROCEDURE checkCanAddRound();

-- fonction trigger de joueur
CREATE OR REPLACE FUNCTION checkNombreDeJoueurParEquipe() RETURNS TRIGGER
AS $BODY$
DECLARE 
    count_joueur smallint;
BEGIN 
    SELECT count(joueur.id) FROM joueur
    WHERE joueur.idEquipe = new.idEquipe
    GROUP BY idEquipe
    INTO count_joueur;
    IF(count_joueur = 5) 
		THEN raise exception 'Il y a déjà 5 joueur dans cette équipe';
        ROLLBACK;    
	END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkSiEquipeEntournoi() RETURNS TRIGGER
AS $BODY$
DECLARE 
	count smallint;
BEGIN
	select count(tournoi_equipe.idtournoi) from tournoi_equipe
	where tournoi_equipe.idtournoi not in (select id from vtournoifini)
	AND tournoi_equipe.idequipe = 
	CASE WHEN TG_OP = 'INSERT' THEN new.idequipe ELSE old.idequipe END
	INTO count;
	if(count > 0) 
		THEN raise exception 'On ne peut pas modifier la liste des joueurs en cours de tournoi';
		ROLLBACK;
	END IF;
	RETURN CASE WHEN TG_OP = 'DELETE' THEN old ELSE new END;
END;  $BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkSiEquipeEntournoiUpdate() RETURNS TRIGGER
AS $BODY$
DECLARE 
	count smallint;
BEGIN
	select count(idtournoi) from tournoi_equipe
	where tournoi_equipe.idtournoi not in (select id from vtournoifini)
	AND tournoi_equipe.idequipe = new.idequipe or tournoi_equipe.idequipe = old.idequipe
	GROUP BY tournoi_equipe.idequipe
	INTO count;
	if(count > 0) 
		THEN raise exception 'On ne peut pas modifier la liste des joueurs en cours de tournoi';
		ROLLBACK;
	END IF;
	RETURN NEW;
END; $BODY$ LANGUAGE plpgsql;
-- trigger de joueur
CREATE OR REPLACE TRIGGER tgr_01_AfterAddUpdateJoueur BEFORE INSERT OR UPDATE on joueur
FOR EACH ROW
EXECUTE PROCEDURE checkNombreDeJoueurParEquipe();
CREATE OR REPLACE TRIGGER tgr_02_AfterAddUpdateJoueur BEFORE INSERT OR DELETE on joueur
FOR EACH ROW
EXECUTE PROCEDURE checkSiEquipeEntournoi();
CREATE OR REPLACE TRIGGER tgr_03_AfterAddUpdateJoueur BEFORE UPDATE on joueur
FOR EACH ROW
EXECUTE PROCEDURE checkSiEquipeEntournoiUpdate();

INSERT INTO pays (nom) VALUES ('Suisse');
INSERT INTO pays (nom) VALUES ('France');
INSERT INTO pays (nom) VALUES ('Italie');
INSERT INTO pays (nom) VALUES ('Espagne');
INSERT INTO pays (nom) VALUES ('Allemagne');
INSERT INTO pays (nom) VALUES ('Pologne');
INSERT INTO pays (nom) VALUES ('Autriche');

INSERT INTO equipe (nom, elo, region) VALUES ('SENTINELS',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('CLOUD9',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('100 THIEVES',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('LOUD',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('KRÜ ESPORTS',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('LEVIATÁN',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('NRG',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('MIBR',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('EVIL GENIUS',1000,'AMERICAS');
INSERT INTO equipe (nom, elo, region) VALUES ('FURIA',1000,'AMERICAS');

INSERT INTO equipe (nom, elo, region) VALUES ('FNATIC',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('TEAM LIQUID',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('TEAM VITALITY',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('KARMINE CORP',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('GIANTS',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('TEAM HERETICS',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('NAVI',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('FUT ESPORTS',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('KOI',1000,'EMEA');
INSERT INTO equipe (nom, elo, region) VALUES ('BBL ESPORTS',1000,'EMEA');

INSERT INTO equipe (nom, elo, region) VALUES ('DRX',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('T1',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('PAPER REX',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('GEN.G',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('GLOBAL ESPORTS',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('TEAM SECRET',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('ZETA DIVISION',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('TALON ESPORTS',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('REX REGUM QEON',1000,'PACIFIC');
INSERT INTO equipe (nom, elo, region) VALUES ('DETONATION GAMING',1000,'PACIFIC');

-- Agent
INSERT INTO agent (nom,role) VALUES ('Jett','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Raze','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Breach','Initiateur');
INSERT INTO agent (nom,role) VALUES ('Omen','Controlleur');
INSERT INTO agent (nom,role) VALUES ('Brimstone','Controlleur');
INSERT INTO agent (nom,role) VALUES ('Phoenix','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Sage','Sentinelle');
INSERT INTO agent (nom,role) VALUES ('Sova','Initiateur');
INSERT INTO agent (nom,role) VALUES ('Viper','Controlleur');
INSERT INTO agent (nom,role) VALUES ('Cypher','Sentinelle');
INSERT INTO agent (nom,role) VALUES ('Reyna','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Killjoy','Sentinelle');
INSERT INTO agent (nom,role) VALUES ('Skye','Initiateur');
INSERT INTO agent (nom,role) VALUES ('Yoru','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Astra','Controlleur');
INSERT INTO agent (nom,role) VALUES ('Kay/o','Initiateur');
INSERT INTO agent (nom,role) VALUES ('Chamber','Sentinelle');
INSERT INTO agent (nom,role) VALUES ('Neon','Duelliste');
INSERT INTO agent (nom,role) VALUES ('Fade','Initiateur');
INSERT INTO agent (nom,role) VALUES ('Harbor','Controlleur');

-- Carte
INSERT INTO carte (nom) VALUES ('Lotus');
INSERT INTO carte (nom) VALUES ('Pearl');
INSERT INTO carte (nom) VALUES ('Fracture');
INSERT INTO carte (nom) VALUES ('Icebox');
INSERT INTO carte (nom) VALUES ('Bind');
INSERT INTO carte (nom) VALUES ('Haven');
INSERT INTO carte (nom) VALUES ('Split');
INSERT INTO carte (nom) VALUES ('Ascent');
INSERT INTO carte (nom) VALUES ('Breeze');

-- Arme
INSERT INTO arme (nom) VALUES ('Classic');
INSERT INTO arme (nom) VALUES ('Shorty');
INSERT INTO arme (nom) VALUES ('Frenzy');
INSERT INTO arme (nom) VALUES ('Ghost');
INSERT INTO arme (nom) VALUES ('Sheriff');
INSERT INTO arme (nom) VALUES ('Stinger');
INSERT INTO arme (nom) VALUES ('Spectre');
INSERT INTO arme (nom) VALUES ('Bucky');
INSERT INTO arme (nom) VALUES ('Judge');
INSERT INTO arme (nom) VALUES ('Bulldog');
INSERT INTO arme (nom) VALUES ('Guardian');
INSERT INTO arme (nom) VALUES ('Phantom');
INSERT INTO arme (nom) VALUES ('Vandal');
INSERT INTO arme (nom) VALUES ('Marshal');
INSERT INTO arme (nom) VALUES ('Operator');
INSERT INTO arme (nom) VALUES ('Ares');
INSERT INTO arme (nom) VALUES ('Odin');
INSERT INTO arme (nom) VALUES ('Couteau tactique');

-- Joueur
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Butler','Cordelia','kedhu','2000-4-7',1273,5,1);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Mills','Michael','bub','1962-9-7',459,6,1);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Gigli','Brian','faodica','1988-4-2',816,1,1);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Oliva','Rena','pog','1961-4-6',44,5,1);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Martinez','Charlie','kobag','1982-8-5',1152,6,1);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Hale','Ryan','zoheme','1964-6-7',1124,1,2);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Franklin','Philip','zimpe','1981-9-7',1871,1,2);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Hughes','Annie','jepfenbif','1970-1-4',1642,2,2);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Leonardi','Emilie','edwig','1986-12-2',1025,5,2);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Sutton','Jorge','evohes','1962-2-3',1180,5,2);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Manni','Edward','koegufuw','1989-5-5',19,2,3);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Mendez','Isaiah','ruvev','1987-10-5',1,2,3);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Patterson','Alice','kovonougo','1976-8-7',1391,6,3);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Marie','Bobby','unepugu','1995-12-4',615,3,3);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Massey','Estella','nir','1981-1-2',1890,1,3);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Garner','Milton','livilabu','1967-10-1',1852,6,4);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Turnbull','Margaret','evgojket','2004-9-1',1205,7,4);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Fukuda','Marguerite','dit','1989-12-1',1094,2,4);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Herrero','Randall','temla','1977-12-4',304,4,4);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bowen','Tommy','ogema','1987-4-4',1074,7,4);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Sanz','Fannie','id','1999-4-3',849,7,5);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('de Lange','Gregory','poisce','1985-11-5',256,5,5);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Calvelli','Daniel','apdewup','1981-3-6',1430,2,5);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Robson','Lydia','kar','1990-9-1',625,2,5);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Knight','Don','jikiz','1979-5-5',572,1,5);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Ludwig','Mabelle','ebe','1968-5-6',1858,2,6);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('van der Wal','Mamie','papidase','1962-5-7',1114,2,6);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Renzi','Laura','go','1996-7-5',411,1,6);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Roy','Lucinda','zesi','1977-4-2',665,1,6);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bulli','Alejandro','ofaom','1998-3-1',894,7,6);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Michaud','Mittie','zonze','1996-7-1',1863,6,7);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Parkin','Amy','ijnen','1972-1-5',1547,1,7);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Silva','Jorge','ejdib','1968-10-7',1176,5,7);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Harvey','Minnie','retuk','1979-2-4',1954,3,7);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Morozzi','Lola','kepemu','2001-11-5',1849,7,7);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Righini','Ivan','gub','1994-2-3',1511,7,8);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Zecchi','Jose','ji','1983-5-7',1563,4,8);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Marie','Irene','labupo','1968-3-7',325,6,8);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Higgins','Annie','kadure','1999-6-2',1368,2,8);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Cousin','Leon','lapukaseb','1989-7-6',1671,7,8);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bonaiuti','Dustin','evo','1962-5-2',318,2,9);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Gensini','Alice','hotcodsah','1992-7-5',1574,1,9);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Barry','Michael','fiplar','1999-3-4',1270,2,9);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('de Bruin','Lilly','sajik','2002-6-4',1897,4,9);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Wheeler','Francisco','ezehabin','1981-9-3',1248,4,9);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Vaughn','Patrick','sit','1976-1-3',24,6,10);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bensi','Justin','sulema','1960-4-7',1812,2,10);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Cohen','Scott','noafo','1999-3-6',1323,1,10);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Graf','Bess','bi','1972-3-5',255,7,10);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Morrison','Sadie','kibcu','2005-3-5',562,2,10);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Rowe','Ora','huvmu','1975-9-5',923,5,11);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('van den Bosch','Troy','tuzipin','2000-6-4',693,1,11);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Pearce','Brian','hu','1986-3-3',1798,5,11);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Perkins','Henry','huv','1972-9-6',1501,6,11);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Sani','Jordan','geodki','1982-3-5',895,2,11);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Chadwick','Winnie','nisgaod','1981-6-1',1889,1,12);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Keller','Patrick','zupvi','1973-4-5',423,3,12);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Simmons','Dollie','weg','1962-5-2',1897,4,12);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Focardi','Katharine','zukahu','1965-10-2',1375,3,12);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Hilton','Elsie','matejlot','1984-12-7',1417,6,12);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Coleman','Loretta','kazice','1964-5-2',710,6,13);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Greer','Nathaniel','bi','1981-7-4',172,7,13);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Fontanelli','Leila','nalebo','1978-4-2',1358,3,13);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Brooks','Sophie','onzifdas','1984-7-5',1753,5,13);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bradshaw','Ray','aj','1972-3-5',758,4,13);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Paoli','Irene','cez','1971-2-2',729,4,14);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Rice','Katherine','lob','2003-12-3',1973,3,14);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Powers','Charlotte','jiskepag','1993-4-3',772,4,14);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Turnbull','Carl','ow','1996-8-4',37,4,14);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Fabbroni','Wayne','jatido','2002-10-7',107,6,14);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Ignesti','Mae','wi','1965-12-6',1408,7,15);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Gensini','Teresa','ge','2003-11-6',939,1,15);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Zoppi','Rosa','dupulal','1987-6-1',1103,1,15);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Pena','Daniel','puofwa','1958-12-3',1800,1,15);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Gilbert','Eugenia','pianoper','2001-2-3',475,4,15);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Turchi','Roy','lized','1958-4-6',881,5,16);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Guichard','Estelle','bavpew','1989-2-7',83,4,16);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Weaver','Edgar','puzte','2005-2-1',1423,5,16);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('de Ruiter','Tyler','hagosjo','1985-9-2',1871,4,16);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Preston','Dora','jol','1976-6-7',1926,3,16);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Tucker','Christian','laub','1963-9-1',1385,7,17);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Chiaramonti','Lucas','epamakoj','1965-7-5',1000,5,17);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Matsuda','Frank','uklu','1984-3-3',1884,2,17);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Orsini','Effie','amlap','1993-2-7',1878,4,17);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Lombardo','Celia','ditigesep','1976-11-2',1571,1,17);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Abbott','Estella','jinjoc','1966-5-5',1726,6,18);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Romano','Glen','toc','1973-9-1',266,1,18);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('van Schaik','Jennie','akmibpus','1978-7-7',937,6,18);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Becker','Irene','biit','1984-2-1',1913,2,18);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Oliver','Leila','igbocru','1978-7-1',1704,3,18);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Salerno','Jane','gawzur','1988-6-6',1569,7,19);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bouman','Ricardo','zedgis','1994-10-6',1959,6,19);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Moody','Noah','gezeffu','1959-9-3',331,7,19);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Pierre','Dora','dalih','1990-7-5',849,4,19);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Howarth','Craig','vuclid','2000-12-2',410,6,19);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Staderini','Nathaniel','zomobcaf','2000-7-6',829,5,20);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Chapman','Dorothy','tacso','2003-7-1',1526,7,20);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Kurt','Inez','ki','1981-5-1',1491,1,20);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Dominguez','Addie','mukistuw','1972-5-2',1036,1,20);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Post','Zachary','rihazaj','1979-6-5',1608,1,20);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Smits','Jessie','ijavi','1973-11-3',1361,7,21);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Connolly','Linnie','kahzemke','1962-9-5',304,4,21);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Yamashita','Gavin','ihedacik','1983-1-3',1873,6,21);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Woodward','Hunter','woddure','1961-3-1',400,6,21);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Carroll','Arthur','ejsafob','1985-9-3',370,7,21);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Pena','Vincent','rit','1984-7-6',1315,2,22);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Huet','Matilda','wozoco','2003-4-2',9,3,22);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('van den Broek','Phillip','hupda','2004-8-3',1885,7,22);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Deschamps','Devin','watge','1974-1-1',606,5,22);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Craig','Elmer','fevi','1966-11-1',844,1,22);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Morley','Betty','uja','1988-5-1',327,6,23);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Nesi','Flora','cinjevofi','1964-6-5',1175,2,23);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Guerrini','Mittie','posalhaf','1989-12-7',520,1,23);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Alblas','Dale','luune','1994-1-2',1962,4,23);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('De Marco','Joe','poj','1983-9-4',1079,2,23);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Jacobs','Vernon','jedohowo','1962-10-3',1983,7,24);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Cellai','Hettie','kekog','2005-6-2',991,5,24);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Mazzetti','Rosalie','baitjim','1991-6-6',1957,1,24);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Ciani','Walter','vike','1985-10-6',570,2,24);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Guarnieri','Vernon','vu','1975-9-3',224,1,24);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Nannini','Peter','puogito','1982-4-1',19,2,25);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Zijlstra','Maggie','apa','1972-3-2',1016,7,25);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Hendriks','Sean','domifa','1984-2-2',565,2,25);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Busch','Leila','la','1982-5-3',1681,7,25);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Hernandez','Charles','numu','1971-7-6',556,6,25);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Cabrera','Gussie','carwaku','1968-4-1',1639,3,26);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Günther','Cole','uli','1982-3-1',1105,4,26);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Brouwer','Ernest','behumic','1979-10-1',1003,1,26);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bessi','Francis','lob','1993-2-2',693,6,26);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Keller','Herbert','jar','1975-10-3',1779,2,26);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Tucker','Clyde','wakdan','1990-7-2',1623,5,27);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Zimmerman','Myra','huof','1975-12-4',1851,3,27);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Randall','Keith','pumakego','1977-7-6',1648,4,27);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Bottai','Amy','citfo','1983-8-2',1153,4,27);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Medina','Blanche','wagez','1987-3-6',1896,7,27);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Grant','Juan','iviuli','1982-10-4',1027,4,28);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Catalano','Richard','zopes','1964-7-4',1708,5,28);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Black','Marvin','ika','1987-5-7',679,3,28);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Falsini','Allen','teuhasiw','1968-12-5',541,6,28);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Poulain','Bess','ton','1960-10-2',11,1,28);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Grossi','Cynthia','pilge','2002-5-5',313,1,29);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Grant','Jane','veh','1997-10-7',1813,3,29);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Maggini','Dollie','je','1993-10-6',120,1,29);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Landini','Della','zokog','1961-12-1',1038,2,29);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Pearce','Mike','fahirec','1975-2-3',1838,3,29);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Austin','Jayden','piha','1985-11-7',1977,2,30);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Marshall','Sean','viciiru','1976-6-6',1145,1,30);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Schulze','Tommy','etiujva','1997-2-4',598,7,30);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Sorbi','Terry','vucga','1965-12-5',1636,4,30);
INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES('Higgins','Jonathan','moktoctek','1966-8-7',22,6,30);
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
	SELECT COUNT(noManche) FROM Manche
	WHERE (idTournoi,noMatch) = (NEW.idTournoi, NEW.noMatch)
	INTO count;
	IF (count > bo) THEN 
		ROLLBACK;
	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkSameCarte() RETURNS TRIGGER
AS $BODY$

DECLARE 
	count_carte SMALLINT;
BEGIN 
	SELECT count(noManche) FROM manche
	WHERE (idTournoi, noMatch) = (new.idTournoi, new.noMatch) AND idCarte = new.idCarte
	INTO count_carte;
	if(count_carte > 1) then 
		ROLLBACK;	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkMancheIsOver() RETURNS TRIGGER
AS $BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(vRoundFini.idVainqueur)
	FROM vRoundFini
	WHERE (vRoundFini.idTournoi, vRoundFini.noMatch, vRoundFini.noManche) = (NEW.idtournoi,new.nomatch, new.nomanche)
	GROUP BY vRoundFini.idTournoi, vRoundFini.noMatch, vRoundFini.noManche, vRoundFini.idVainqueur
	HAVING count(*) = 13
	ORDER BY manche.idTournoi, manche.noMatch, manche.noManche
	INTO count;
	IF(count > 0) THEN 
		raise exception 'Le match est fini, on ne peut pas ajouter de manche supplémentaire!';
		PERFORM matchFini(new.idtournoi,new.nomatch);
		ROLLBACK;
	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION matchFini(idT manche.idtournoi%type ,noM manche.nomatch%type) returns void
AS $BODY$
DECLARE 
	noMatchSuivant match.noMatchSuivant%type;
	idVainqueur vmatchfini.idvainqueur%type;
BEGIN 
	SELECT match.nomatchsuivant FROM match WHERE match.idtournoi = idT and match.nomatch = noM INTO nomatchsuivant;
	SELECT vmatchfini.idvainqueur from vmatchfini where vmatchfini.idtournoi = idT and vmatchfini.nomatch = noM INTO idVainqueur;
	UPDATE match 
	SET
	idequipegauche =
	CASE 
		WHEN noM <= all (select nomatch FROM match where match.idtournoi = idT and match.nomatchsuivant = nomatchsuivant)
		THEN idvainqueur
		ELSE idequipegauche
	END,
	idequipedroite =
	CASE 
		WHEN noM >= all (select nomatch FROM match where match.idtournoi = idT and match.nomatchsuivant = nomatchsuivant)
		THEN idvainqueur 
		ELSE  idequipedroite
	END;
END;
$BODY$ LANGUAGE plpgsql;


-- trigger de manche
CREATE OR REPLACE TRIGGER tgr_01_InsertManche BEFORE INSERT on Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkMancheIsOver();
CREATE OR REPLACE TRIGGER tgr_02_InsertManche AFTER INSERT on Manche 
FOR EACH ROW
EXECUTE PROCEDURE checkNumberManche();
CREATE OR REPLACE TRIGGER tgr_03_InsertManche AFTER INSERT on Manche 
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
		THEN ROLLBACK;
	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;
--change to checkcanaddmatch utiliser tournoifini
CREATE OR REPLACE FUNCTION checkMatchIsOver() RETURNS TRIGGER
AS $BODY$

DECLARE 
	count SMALLINT;
BEGIN 
	SELECT COUNT(idVainqueur) FROM vMatchFini 
	WHERE (vMatchFini.idTournoi,vMatchFini.noMatch) = (NEW.idtournoi,NEW.noMatch)
	GROUP BY vMatchFini.idTournoi,vMatchFini.noMatch
	INTO count;
	IF(count > 0) THEN 
		ROLLBACK;
	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de match
--CREATE OR REPLACE TRIGGER tgr_01_InsertMatch BEFORE INSERT on match
--FOR EACH ROW
--EXECUTE PROCEDURE checkMatchIsOver();
CREATE OR REPLACE TRIGGER tgr_02_InsertMatch AFTER INSERT on match
FOR EACH ROW
EXECUTE PROCEDURE checkMatchDate();

-- fonction trigger de kill
CREATE OR REPLACE FUNCTION checkKillSameTeam() RETURNS TRIGGER AS
$BODY$

BEGIN
	IF((SELECT idEquipe FROM joueur where id = new.idTueur) = (SELECT idEquipe FROM Joueur WHERE id = new.idMort)) THEN 
		raise exception 'Un joueur ne peux pas tuer un joueur de son équipe';
	
	END IF;
	RETURN NULL;
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
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkRoundIsOver() RETURNS TRIGGER AS 
$BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT count(equipe.id)
	FROM round 
	INNER JOIN match on (match.idTournoi,match.noMatch) = (round.idTournoi, round.noMatch)
	INNER JOIN kill on (round.idTournoi, round.noMatch, round.noManche, round.noRound) = (kill.idTournoi, kill.noMatch, kill.noManche, kill.noRound)
	INNER JOIN joueur on kill.idTueur = joueur.id
	INNER JOIN equipe on joueur.idEquipe = equipe.id
	WHERE (round.idtournoi, round.nomatch, round.nomanche, round.noround) = (new.idtournoi,new.nomatch,new.nomanche,new.noround)
	GROUP BY round.idtournoi, round.nomatch, round.nomanche, round.noround, equipe.id
	HAVING count(*) = 5
	INTO count;
	IF(count > 0) THEN 
		raise exception 'La manche est fini, on ne peut pas ajouter de round supplémentaire!';
		ROLLBACK;	
	END IF;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checkCanAddKill() RETURNS TRIGGER AS 
$BODY$
DECLARE 
	count SMALLINT;
BEGIN 
	SELECT COUNT(idVainqueur) FROM vRoundFini
	WHERE (vRoundFini.idtournoi,vRoundFini.nomatch,vRoundFini.nomanche,vRoundFini.noround) = (new.idtournoi,new.nomatch,new.nomanche,new.noround)
	GROUP BY vRoundFini.idtournoi,vRoundFini.nomatch,vRoundFini.nomanche,vRoundFini.noround
	INTO count;
	if(count > 0) 
	THEN
		raise exception 'Le round est fini, on ne peut pas ajouter de kill supplémentaire!';
		ROLLBACK;
	
	end if;
	RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de kill
CREATE OR REPLACE TRIGGER tgr_01_AfterAddKill AFTER INSERT on Kill
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
CREATE OR REPLACE TRIGGER tgr_01_BeforeAddRound AFTER INSERT on round
FOR EACH ROW
EXECUTE PROCEDURE checkRoundIsOver();

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
    IF(count_joueur > 5) 
		THEN raise exception 'Il y a déjà 5 joueur dans cette équipe';
        ROLLBACK;
    
	END IF;
    RETURN NULL;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de joueur
CREATE OR REPLACE TRIGGER tgr_01_AfterAddUpdateJoueur BEFORE INSERT OR UPDATE on joueur
FOR EACH ROW
EXECUTE PROCEDURE checkNombreDeJoueurParEquipe();
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



CREATE OR REPLACE FUNCTION matchFini(idT manche.idtournoi%type ,noM manche.nomatch%type) returns void
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
	SELECT COUNT(idVainqueur) FROM vMatchFini 
	WHERE (vMatchFini.idTournoi,vMatchFini.noMatch) = (NEW.idtournoi,NEW.noMatch)
	GROUP BY vMatchFini.idTournoi,vMatchFini.noMatch
	INTO count;
	IF(count > 0) THEN 
		raise exception 'Le tournoi est fini!';
		ROLLBACK;
	
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de match
--CREATE OR REPLACE TRIGGER tgr_01_InsertMatch BEFORE INSERT on match
--FOR EACH ROW
--EXECUTE PROCEDURE checkCanAddMatch();
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
    IF(count_joueur > 5) 
		THEN raise exception 'Il y a déjà 5 joueur dans cette équipe';
        ROLLBACK;    
	END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- trigger de joueur
CREATE OR REPLACE TRIGGER tgr_01_AfterAddUpdateJoueur BEFORE INSERT OR UPDATE on joueur
FOR EACH ROW
EXECUTE PROCEDURE checkNombreDeJoueurParEquipe();
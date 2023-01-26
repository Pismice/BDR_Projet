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

DROP VIEW IF EXISTS vJoueurStat CASCADE;
CREATE VIEW vJoueurStat AS 
SELECT joueur.id,joueur.nom,joueur.prenom,joueur.pseudonyme, 
COALESCE(sum(case when Kill.idTueur = joueur.id then 1 end),0) as nombreKill, 
COALESCE(sum(case when Joueur_Agent_Manche.idJoueur = joueur.id then 1 end),0) as nombreMancheJouer,
COALESCE(sum(case when vMancheFini.idVainqueur = joueur.idEquipe then 1 end),0) as nombreMancheGagnee
FROM joueur
LEFT JOIN Kill on joueur.id = kill.idTueur
LEFT JOIN Joueur_Agent_Manche on Joueur_Agent_Manche.idJoueur = joueur.id
LEFT JOIN vMancheFini on joueur.idEquipe = vMancheFini.idVainqueur
GROUP BY joueur.id;

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
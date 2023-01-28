using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class TournoiService
    {
        private readonly ValoContext _context;
        public TournoiService(ValoContext context)
        {
            _context = context;
        }

        public Tournoi[]? GetAll()
        {
            return _context.Tournoi.FromSqlRaw("SELECT * FROM tournoi").ToArray();
        }

        public Tournoi? GetById(Int16 id) 
        {
            FormattableString query = $"SELECT * FROM tournoi WHERE id = {id};";
            return _context.Tournoi.FromSqlInterpolated(query).ToArray()[0];
        }

        public Equipe[]? GetEquipeFromTournoi(Int16 id)
        {
            FormattableString query = $"SELECT equipe.* FROM equipe INNER JOIN tournoi_equipe ON equipe.id = tournoi_equipe.idequipe WHERE tournoi_equipe.idtournoi = {id};";
            return _context.Equipe.FromSqlInterpolated(query).ToArray();
        }

        public void Add(Tournoi t) 
        {
            FormattableString query = $"INSERT INTO tournoi (nom,cashprize,point,datedebut,datefin) VALUES ({t.Nom},{t.CashPrize},{t.Point},{t.DateDebut},{t.DateFin});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddEquipe(Tournoi t,Equipe e)
        {
            FormattableString query = $"INSERT INTO tournoi_equipe (idtournoi, idequipe) VALUES ({t.Id},{e.Id});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddMatch(Int16 idTournoi,Int16 noMatch,GameFormat format, DateOnly gamedate,Int16? noMatchSuivant = null)
        {
            FormattableString query = $"INSERT INTO match (idTournoi,noMatch,gameformat, gamedate,nomatchsuivant) VALUES ({idTournoi},{noMatch},{format},{gamedate},{noMatchSuivant});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void DeleteEquipe(Tournoi t, Equipe e)
        {
            FormattableString query = $"DELETE FROM tournoi_equipe WHERE idTournoi = {t.Id} AND idEquipe = {e.Id};";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void Update(Tournoi t)
        {
            FormattableString query = $"UPDATE tournoi SET nom = {t.Nom},cashprize = {t.CashPrize},point = {t.Point},datedebut = {t.DateDebut},datefin = {t.DateFin} WHERE id = {t.Id};";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Delete(Int16 id)
        {
            FormattableString query = $"DELETE FROM tournoi WHERE id = {id};";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public Data.Match[] GetAllMatch(Int16 idTournoi)
        {
            FormattableString query = $"SELECT match.* FROM match WHERE idTournoi = {idTournoi};";
            return _context.Match.FromSqlInterpolated(query).ToArray();
        }

        public VTournoiMatch[] GetAllVMatch(Int16 idTournoi)
        {
            FormattableString query = $"SELECT * FROM vtournoimatch WHERE idTournoi = {idTournoi};";
            return _context.VTournoiMatch.FromSqlInterpolated(query).ToArray();
        }

        public void UpdateMatch(Int16 idTournoi, Int16 noMatch, Int16 idEquipeGauche, Int16 idEquipeDroite)
        {
            FormattableString query = $"UPDATE match SET idequipegauche = {idEquipeGauche}, idequipedroite = {idEquipeDroite} WHERE idtournoi = {idTournoi} and noMatch = {noMatch};";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        
        public VMatchFini? GetVMatchFini(Int16 idTournoi, Int16 noMatch)
        {
            FormattableString query = $"SELECT * FROM vmatchfini WHERE idtournoi = {idTournoi} and nomatch = {noMatch};";
            VMatchFini[]? v = _context.VMatchFini.FromSqlInterpolated(query).ToArray();
            if (v.Length == 0)
            {
                return null;
            }
            return v[0];
        }

        public VMancheFini[]? GetVMancheFinis(Int16 idTournoi, Int16 noMatch)
        {
            FormattableString query = $"SELECT * FROM vmanchefini WHERE idtournoi = {idTournoi} and nomatch = {noMatch};";
            return _context.VMancheFini.FromSqlInterpolated(query).ToArray();
        }

        public Match GetMatch(Int16 idTournoi, Int16 noMatch)
        {
            FormattableString query = $"SELECT * FROM match WHERE idtournoi = {idTournoi} and nomatch = {noMatch};";
            return _context.Match.FromSqlInterpolated(query).ToArray()[0];
        }
        public VTournoiMatch GetVMatch(Int16 idTournoi, Int16 noMatch)
        {
            FormattableString query = $"SELECT * FROM vtournoimatch WHERE idtournoi = {idTournoi} and nomatch = {noMatch};";
            return _context.VTournoiMatch.FromSqlInterpolated(query).ToArray()[0];
        }

        public int GetScoreMatch(Int16 idTournoi, Int16 noMatch,Int16? idEquipe)
        {
            FormattableString query = $"SELECT count(*) as value FROM vmanchefini WHERE idtournoi = {idTournoi} and nomatch = {noMatch} and idvainqueur = {idEquipe};";
            return _context.Int.FromSql(query).ToArray()[0].value;            
        }

        public int GetScoreManche(Int16 idTournoi, Int16 noMatch,Int16 noManche, Int16? idEquipe)
        {
            FormattableString query = $"SELECT count(*) as value FROM vroundfini WHERE idtournoi = {idTournoi} and nomatch = {noMatch} and nomanche = {noManche} and idvainqueur = {idEquipe};";
            return _context.Int.FromSql(query).ToArray()[0].value;
        }

        public VRoundFini[]? GetRoundManche(Int16 idTournoi, Int16 noMatch, Int16 noManche)
        {
            FormattableString query = $"SELECT * FROM vroundfini WHERE idtournoi = {idTournoi} and nomatch = {noMatch} and nomanche = {noManche} ORDER BY noround ASC;";
            return _context.VRoundFini.FromSql(query).ToArray();
        }

        public Match GetNextMatch(Int16 idTournoi)
        {
            FormattableString query = $"SELECT * FROM match WHERE idtournoi = {idTournoi} and (match.idtournoi,match.nomatch) not in (SELECT idtournoi,nomatch from vmatchfini)\r\nGROUP BY (match.idtournoi,match.nomatch) HAVING match.nomatch <= ALL(SELECT match.nomatch FROM match WHERE (match.idtournoi,match.nomatch) not in (SELECT idtournoi,nomatch from vmatchfini));";
            return _context.Match.FromSqlInterpolated(query).ToArray()[0];
        }

        public bool IsMatchDone(Int16 idTournoi,Int16 noMatch) 
        {
            FormattableString query = $"SELECT * FROM vmatchfini WHERE idtournoi = {idTournoi} and nomatch = {noMatch};";
            return _context.VMatchFini.FromSqlInterpolated(query).ToArray().Length == 1;
        }
        public bool IsMancheDone(Int16 idTournoi, Int16 noMatch,Int16 noManche)
        {
            FormattableString query = $"SELECT * FROM vmanchefini WHERE idtournoi = {idTournoi} and nomatch = {noMatch} and nomanche = {noManche};";
            return _context.VMancheFini.FromSqlInterpolated(query).ToArray().Length == 1;
        }

        public bool IsRoundDone(Int16 idTournoi, Int16 noMatch, Int16 noManche, Int16 noRound)
        {
            FormattableString query = $"SELECT * FROM vroundfini WHERE idtournoi = {idTournoi} and nomatch = {noMatch} and nomanche = {noManche} and noround = {noRound};";
            return _context.VRoundFini.FromSqlInterpolated(query).ToArray().Length == 1;
        }

        public bool IsTournoiDone(Int16 idTournoi)
        {
            FormattableString query = $"SELECT * FROM vtournoifini WHERE id = {idTournoi};";
            return _context.VTournoiFini.FromSqlInterpolated(query).ToArray().Length == 1;
        }
        public void AddManche(Manche m)
        {
            FormattableString query = $"INSERT INTO manche (idtournoi,nomatch,nomanche,idcarte) VALUES ({m.IdTournoi},{m.NoMatch},{m.NoManche},{m.IdCarte});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddRound(Round r)
        {
            FormattableString query = $"INSERT INTO round (idtournoi,nomatch,nomanche,noround) VALUES ({r.IdTournoi},{r.NoMatch},{r.NoManche},{r.NoRound});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddKill(Kill k)
        {
            FormattableString query = $"INSERT INTO kill (idtournoi,nomatch,nomanche,noround,nokill,idtueur,idmort,idarme) VALUES ({k.IdTournoi},{k.NoMatch},{k.NoManche},{k.NoRound},{k.NoKill},{k.IdTueur},{k.IdMort},{k.IdArme});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void MatchFini(Match m)
        {
            FormattableString query = $"SELECT matchfini({m.IdTournoi},{m.NoMatch});";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddJoueurAgentManche(Int16 idJoueur, Int16 idTournoi, Int16 noMatch, Int16 noManche,Int16 idAgent)
        {
            FormattableString query = $"INSERT INTO joueur_agent_manche (idjoueur,idtournoi,nomatch,nomanche,idagent) VALUES ({idJoueur},{idTournoi},{noMatch},{noManche},{idAgent});";
            _context.Database.ExecuteSqlInterpolated(query);
        }
    }
}

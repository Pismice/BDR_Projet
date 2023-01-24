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
            FormattableString query = $"SELECT * FROM tournoi WHERE id = {id}";
            return _context.Tournoi.FromSqlInterpolated(query).ToArray()[0];
        }

        public Equipe[]? GetEquipeFromTournoi(Int16 id)
        {
            FormattableString query = $"SELECT equipe.* FROM equipe INNER JOIN tournoi_equipe ON equipe.id = tournoi_equipe.idequipe WHERE tournoi_equipe.idtournoi = {id}";
            return _context.Equipe.FromSqlInterpolated(query).ToArray();
        }

        public void Add(Tournoi t) 
        {
            FormattableString query = $"INSERT INTO tournoi (nom,cashprize,point,datedebut,datefin) VALUES ({t.Nom},{t.CashPrize},{t.Point},{t.DateDebut},{t.DateFin})";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void AddEquipe(Tournoi t,Equipe e)
        {
            FormattableString query = $"INSERT INTO tournoi_equipe (idtournoi, idequipe) VALUES ({t.Id},{e.Id})";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void DeleteEquipe(Tournoi t, Equipe e)
        {
            FormattableString query = $"DELETE FROM tournoi_equipe WHERE idTournoi = {t.Id} AND idEquipe = {e.Id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }

        public void Update(Tournoi t)
        {
            FormattableString query = $"UPDATE tournoi SET nom = {t.Nom},cashprize = {t.CashPrize},point = {t.Point},datedebut = {t.DateDebut},datefin = {t.DateFin} WHERE id = {t.Id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Delete(Int16 id)
        {
            FormattableString query = $"DELETE FROM tournoi WHERE id = {id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
    }
}

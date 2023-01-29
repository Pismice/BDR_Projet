using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class EquipeService
    {
        private readonly ValoContext _context;
        public EquipeService(ValoContext context)
        {
            _context = context;
        }
        public Equipe[]? GetAll()
        {
            return _context.Equipe.FromSqlRaw("SELECT * FROM equipe ORDER BY id").ToArray();
        }
        public Equipe[]? GetTransferable() {
            return _context.Equipe.FromSqlRaw("select * from equipe where id not in (select idequipe from tournoi_equipe where idtournoi not in (select idtournoi from vtournoifini));").ToArray();
        }
        public Equipe? GetById(Int16 id)
        {
            FormattableString query = $"SELECT * FROM equipe WHERE id = {@id}";
            return _context.Equipe.FromSqlInterpolated(query).ToArray()[0];
        }
        public Joueur[]? GetJoueurs(Int16 id)
        {
            FormattableString query = $"SELECT * FROM joueur where idequipe = {@id}";
            return _context.Joueur.FromSqlInterpolated(query).ToArray();
        }
        public string? GetName(Int16 id)
        {
            FormattableString query = $"SELECT * FROM equipe WHERE id = {id}";
            return _context.Equipe.FromSqlInterpolated(query).ToArray()[0].Nom;
        }
        public void Add(Equipe e)
        {
            FormattableString query = $"INSERT INTO equipe (nom,elo,region) VALUES ({e.Nom},{e.Elo},{e.Region})";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Update(Equipe e)
        {
            FormattableString query = $"UPDATE equipe SET nom = {e.Nom}, elo = {e.Elo}, region = {e.Region} WHERE id = {e.Id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Delete(Int16 id)
        {
            FormattableString query = $"DELETE FROM equipe WHERE id = {id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public Equipe[]? GetClassement(Region r)
        {
            FormattableString query = $"SELECT * FROM equipe WHERE region = {@r} ORDER BY elo DESC";
            return _context.Equipe.FromSqlInterpolated(query).ToArray();
        }

        public VEquipeStat[] GetAllStat(string filter)
        {
            FormattableString query;
            switch (filter)
            {
                case "nombretournoijouer":
                    query = $"SELECT * FROM vequipestat ORDER BY nombretournoijouer DESC";
                    break;
                case "nombrematchjouer":
                    query = $"SELECT * FROM vequipestat ORDER BY nombrematchjouer DESC";
                    break;
                case "nombrematchgagnee":
                    query = $"SELECT * FROM vequipestat ORDER BY nombrematchgagnee DESC";
                    break;
                default : return new VEquipeStat[0];
            }
            
            return _context.VEquipeStat.FromSqlInterpolated(query).ToArray();
        }
        public VEquipeStat GetStatById(Int16 id)
        {
            FormattableString query = $"SELECT * FROM vequipestat WHERE id = {id}";
            VEquipeStat[] ves = _context.VEquipeStat.FromSqlInterpolated(query).ToArray();
            if(ves.Length == 0)
            {
                return null;
            }
            return ves[0];
        }
    }
}

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
        public Equipe[] GetAll()
        {
            return _context.Equipe.FromSqlRaw("SELECT * FROM equipe ORDER BY id").ToArray();
        }

        public Equipe GetById(Int16 id)
        {
            FormattableString query = $"SELECT * FROM equipe WHERE id = {@id}";
            return _context.Equipe.FromSqlInterpolated(query).ToArray()[0];
        }
        public string GetName(Int16 id)
        {
            FormattableString query = $"SELECT nom FROM equipe WHERE id = {id}";
            return _context.Equipe.FromSqlInterpolated(query).ToArray()[0].Nom;
        }
        public void Update(Equipe e)
        {
            FormattableString query = $"UPDATE equipe SET nom = {e.Nom}, elo = {e.Elo}, region = {e.Region} WHERE id = {e.Id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
    }
}

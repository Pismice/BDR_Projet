using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class PaysService
    {
        private readonly ValoContext _context;
        public PaysService(ValoContext context)
        {
            _context = context;
        }

        public Pays[] GetAll()
        {
            return _context.Pays.FromSqlRaw("SELECT * FROM pays").ToArray();
        }

        public string GetName(Int16 id)
        {
            FormattableString query = $"SELECT * FROM pays WHERE id = {id}";
            return _context.Pays.FromSqlInterpolated(query).ToArray()[0].Nom;
        }
    }
}

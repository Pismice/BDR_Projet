using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class ArmeService
    {
        private readonly ValoContext _context;

        public ArmeService(ValoContext context)
        {
            _context = context;
        }

        public Arme[] GetAll()
        {
            FormattableString query = $"SELECT * FROM arme";
            return _context.Arme.FromSqlInterpolated(query).ToArray();
        }
        public VArmeStat[]? GetVArmeStats()
        {
            FormattableString query = $"SELECT * FROM varmestat ORDER BY nombrekills DESC";
            return _context.VArmeStat.FromSqlInterpolated(query).ToArray();
        }
    }
}

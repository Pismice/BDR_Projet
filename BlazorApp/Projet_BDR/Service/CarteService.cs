using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class CarteService
    {
        ValoContext _context;
        public CarteService(ValoContext context)
        {
            _context = context;
        }

        public Carte[] GetAll()
        {
            FormattableString query = $"SELECT * FROM carte";
            return _context.Carte.FromSqlInterpolated(query).ToArray();
        }

        public VCarteStat[] GetVCarteStat()
        {
            FormattableString query = $"SELECT * FROM vcartestat order by nombredefoisjouee desc";
            return _context.VCarteStat.FromSqlInterpolated(query).ToArray();
        }
    }
}

using Projet_BDR.Context;

namespace Projet_BDR.Service
{
    public class MancheService
    {
        private readonly ValoContext _context;

        public MancheService(ValoContext context)
        {
            _context = context;
        }
    }
}

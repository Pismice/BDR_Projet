using Projet_BDR.Context;

namespace Projet_BDR.Service
{
    public class RoundService
    {
        private readonly ValoContext _context;

        public RoundService(ValoContext context)
        {
            _context = context;
        }
    }
}

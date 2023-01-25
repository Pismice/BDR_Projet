using Projet_BDR.Context;

namespace Projet_BDR.Service
{
    public class MatchService
    {
        private readonly ValoContext _context;

        public MatchService(ValoContext context)
        {
            _context = context;
        }
    }
}

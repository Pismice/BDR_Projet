using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;

namespace Projet_BDR.Service
{
    public class AgentService
    {
        private readonly ValoContext _context;

        public AgentService(ValoContext context)
        {
            _context = context;
        }

        public Agent[] GetAll()
        {
            FormattableString query = $"select * from agent";
            return _context.Agent.FromSqlInterpolated(query).ToArray();
        }
    }
}

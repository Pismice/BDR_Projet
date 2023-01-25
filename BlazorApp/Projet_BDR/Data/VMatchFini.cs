using Microsoft.EntityFrameworkCore;

namespace Projet_BDR.Data
{
    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch))]
    public class VMatchFini
    {
        public Int16 IdTournoi { get; set; }
        public Int16 NoMatch { get; set; }
        public Int16 IdVainqueur { get; set; }
    }
}

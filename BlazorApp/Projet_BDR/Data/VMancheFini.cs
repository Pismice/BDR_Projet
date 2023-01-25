using Microsoft.EntityFrameworkCore;

namespace Projet_BDR.Data
{
    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch), nameof(NoManche))]
    public class VMancheFini
    {
        public Int16 IdTournoi { get; set; }
        public Int16 NoMatch { get; set; }
        public Int16 NoManche { get; set; }
        public Int16 IdVainqueur { get; set; }
    }
}

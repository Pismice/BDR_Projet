using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{

    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch), nameof(NoManche), nameof(NoRound),nameof(NoKill))]
    public class Kill
    {
        public Int16 IdTournoi { get; set; }
        public Int16 NoMatch { get; set; }
        public Int16 NoManche { get; set; }
        public Int16 NoRound { get; set; }
        public Int16 NoKill { get; set; }
        public Int16 IdTueur { get; set; }
        public Int16 IdMort { get; set; }
        public Int16 IdArme { get; set; }
    }
}

using Microsoft.AspNetCore.Routing.Matching;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Numerics;

namespace Projet_BDR.Data
{

    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch), nameof(NoManche),nameof(NoRound))]
    public class Round
    {
        const Int16 MAX_KILL = 9;

        
        public Int16 IdTournoi { get; set; }
        
        public Int16 NoMatch { get; set; }
        
        public Int16 NoManche { get; set; }
        
        public Int16 NoRound { get; set; }

        Kill[] Kills { get; set; } = new Kill[MAX_KILL];
    }
}

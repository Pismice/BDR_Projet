using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Projet_BDR.Data
{

    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch), nameof(NoManche))]
    public class Manche
    {
        public Int16 IdTournoi { get; set; }
        
        public Int16 NoMatch { get; set; }
        
        public Int16 NoManche { get; set; }

        [ForeignKey("Carte")]
        public Int16 NoCarte { get; set; }
    }
}

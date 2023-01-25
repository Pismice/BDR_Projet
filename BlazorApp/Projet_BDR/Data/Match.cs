using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public enum GameFormat { BO1,BO3,BO5 }
    [PrimaryKey(nameof(IdTournoi), nameof(NoMatch))]
    public class Match
    {
        
        public Int16 IdTournoi { get; set; }
        
        public Int16 NoMatch { get; set; }
        [Required]
        public GameFormat GameFormat { get; set; }
        [Required]
        public DateTime GameDate { get; set; }
        public Int16? NoMatchSuivant { get; set; }
    }
}

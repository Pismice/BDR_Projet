using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class Carte
    {
        [Key]
        public Int16 id { get; set; }
        [Required]
        public string nom { get; set; }
    }
}

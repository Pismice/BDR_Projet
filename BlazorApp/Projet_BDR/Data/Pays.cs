using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class Pays
    {
        [Key]
        public Int16 Id { get; set; }
        [Required]
        public string Nom { get; set; }
    }
}

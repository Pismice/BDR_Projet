using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class Arme
    {
        [Key]
        public Int16 Id { get; set; }

        [Required]
        public string Nom { get; set; }
    }
}

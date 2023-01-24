using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Projet_BDR.Data
{
    public class Joueur
    {
        [Key]
        public Int16 Id { get; set; }
        [Required]
        public string Nom { get; set; }
        [Required]
        public string Prenom { get; set; }
        [Required]
        public string Pseudonyme { get; set; }
        [Required]
        public DateOnly DateNaissance { get; set; }
        [Required]
        public Int16 Salaire { get; set; }
        [ForeignKey("Pays")]
        public Int16 IdPays { get; set; }
        [ForeignKey("Equipe")]
        public Int16 IdEquipe { get; set; }
    }
}

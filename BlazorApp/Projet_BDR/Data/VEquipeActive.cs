using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VEquipeActive
    {
        [Key]
        public Int16 Id { get; set; }
        public string Nom { get; set; }
        public Int16 Elo { get; set; }
        public Region Region { get; set; }
    }
}

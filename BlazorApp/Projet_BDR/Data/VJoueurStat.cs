using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VJoueurStat
    {
        [Key]
        public Int16 Id { get; set; }
        public string Nom { get; set; }
        public string Prenom { get; set; }
        public string Pseudonyme { get; set; }
        public int? NombreKill { get; set; }
        public int? NombreMort { get; set; }
        public int? NombreMancheJouer { get; set; }
        public int? NombreMancheGagnee { get; set; }
    }
}

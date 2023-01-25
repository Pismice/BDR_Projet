using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VArmeStat
    {
        [Key]
        public Int16 Id { get; set; }
        public string Nom { get; set; }
        public int NombreKills { get; set; }
    }
}

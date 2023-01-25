using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VEquipeStat
    {
        [Key]
        public Int16 Id {get;set;}
        public string Nom { get;set;}
        public int NombreTournoiJouer { get;set;}
        public int NombreMatchJouer { get;set;}
        public int NombreMatchGagnee { get;set;}
    }
}

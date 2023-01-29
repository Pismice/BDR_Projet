using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VCarteStat
    {
        public Int16 id { get; set; }
        public string nom { get; set; }
        public Int16 NombreDeFoisJouee { get; set; }
    }
}

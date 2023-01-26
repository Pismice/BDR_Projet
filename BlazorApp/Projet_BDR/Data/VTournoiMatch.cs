using Microsoft.EntityFrameworkCore;

namespace Projet_BDR.Data
{
    [PrimaryKey(nameof(IdTournoi),nameof(NoMatch))]
    public class VTournoiMatch
    {
        public Int16 IdTournoi { get; set; }

        public Int16 NoMatch { get; set; }
        public Int16? IdEquipeGauche { get; set; }
        public Int16? IdEquipeDroite { get; set; }
        public string NomEquipeGauche { get; set; }
        public string NomEquipeDroite { get; set; }
    }
}

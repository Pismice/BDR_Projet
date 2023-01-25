using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    [PrimaryKey(nameof(IdJoueur),nameof(IdAgent))]
    public class VJoueurAgent
    {
        public Int16 IdJoueur { get; set; }
        public Int16 IdAgent { get; set; }
        public string AgentNom { get; set; }
        public int NombreFoisJouer { get; set; }
    }
}
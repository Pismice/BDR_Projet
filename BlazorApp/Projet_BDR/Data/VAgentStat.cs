using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public class VAgentStat
    {
        [Key]
        public Int16 Id { get; set; }
        public string Nom { get; set; }
        public AgentType Role { get; set; }
        public int NombreFoisJouer { get; set; }
        public int NombreDeKill { get; set; }
    }
}

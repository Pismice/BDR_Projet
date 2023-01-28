using System;
using System.ComponentModel.DataAnnotations;
using NpgsqlTypes;

namespace Projet_BDR.Data
{
    public enum AgentType {
        [PgName("Sentinelle")] Sentinelle,
        [PgName("Controlleur")] Controlleur,
        [PgName("Duelliste")] Duelliste,
        [PgName("Initiateur")] Initiateur}
    public class Agent
    {
        [Key]
        public Int16 Id { get; set; }
        [Required]
        public string Nom { get; set; }
        public AgentType Role { get; set; }
    }
}

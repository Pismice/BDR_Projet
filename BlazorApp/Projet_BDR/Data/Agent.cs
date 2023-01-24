using System;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public enum AgentType {Sentinelle,Controller, Duelliste, Initiateur}
    public class Agent
    {
        [Key]
        public Int16 Id { get; set; }
        [Required]
        public string Nom { get; set; }
        public AgentType Role { get; set; }
    }
}

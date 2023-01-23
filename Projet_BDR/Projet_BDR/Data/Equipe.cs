using NpgsqlTypes;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    public enum Region {
        [PgName("AMERICAS")]
        AMERICAS,
        [PgName("PACIFIC")]
        PACIFIC,
        [PgName("EMEA")]
        EMEA};
    
    public class Equipe
    {
        [Key]
        public Int16 Id { get; set; }
        [Required]
        public string Nom { get; set; }
        [Required]
        public Int16 Elo { get; set; }
        [Required]
        public Region Region { get; set; }
    }
}

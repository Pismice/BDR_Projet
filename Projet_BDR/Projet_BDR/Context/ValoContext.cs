using Microsoft.EntityFrameworkCore;
using Npgsql;
using Projet_BDR.Data;

namespace Projet_BDR.Context
{
    public class ValoContext : DbContext
    {
        public ValoContext(DbContextOptions options) : base(options) { }
        public DbSet<Agent> Agents { get; set; }
        public DbSet<Arme> Arme { get; set; }
        public DbSet<Carte> Carte { get; set; }
        public DbSet<Equipe> Equipe { get; set; }
        public DbSet<Joueur> Joueur { get; set; }
        public DbSet<Kill> Kill { get; set; }
        public DbSet<Manche> Manche { get; set; }
        public DbSet<Match> Match { get; set; }
        public DbSet<Pays> Pays { get; set; }
        public DbSet<Round> Round { get; set; }
        public DbSet<Tournoi> Tournoi { get; set; }

        static ValoContext()  
        {
            NpgsqlConnection.GlobalTypeMapper.MapEnum<Region>();
            NpgsqlConnection.GlobalTypeMapper.MapEnum<AgentType>();
        }

    }
}

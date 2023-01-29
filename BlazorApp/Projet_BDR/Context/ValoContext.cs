using Microsoft.EntityFrameworkCore;
using Npgsql;
using Projet_BDR.Data;

namespace Projet_BDR.Context
{
    public class ValoContext : DbContext
    {
        public ValoContext(DbContextOptions options) : base(options) { }
        public DbSet<Agent> Agent { get; set; }
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
        public DbSet<VAgentStat> VAgentStat { get; set; }
        public DbSet<VArmeStat> VArmeStat { get; set; }
        public DbSet<VEquipeActive> VEquipeActive { get; set; }
        public DbSet<VEquipeStat> VEquipeStat { get; set; }
        public DbSet<VJoueurAgent> VJoueurAgent { get; set; }
        public DbSet<VJoueurStat> VJoueurStat { get; set; }
        public DbSet<VMancheFini> VMancheFini { get; set; }        
        public DbSet<VRoundFini> VRoundFini{ get; set; }        
        public DbSet<VMatchFini> VMatchFini { get; set; }
        public DbSet<VTournoiMatch> VTournoiMatch { get; set; }
        public DbSet<VTournoiFini> VTournoiFini { get; set; }
        public DbSet<DbInt> Int { get; set; }

        static ValoContext()  
        {
            NpgsqlConnection.GlobalTypeMapper.MapEnum<Region>();
            NpgsqlConnection.GlobalTypeMapper.MapEnum<AgentType>();
            NpgsqlConnection.GlobalTypeMapper.MapEnum<GameFormat>();
        }

    }
}

using Microsoft.EntityFrameworkCore;
using Projet_BDR.Context;
using Projet_BDR.Data;
using System.ComponentModel;

namespace Projet_BDR.Service
{
    public class JoueurService
    {
        private readonly ValoContext _context;
        public JoueurService(ValoContext context) {
            _context = context;
        }

        public Joueur[] GetAll()
        {
            return _context.Joueur.FromSqlRaw("SELECT * FROM joueur").ToArray();
        }

        public void AddJoueur(Joueur j)
        {
            FormattableString query = $"INSERT INTO joueur (nom,prenom,pseudonyme,dateNaissance,salaire,idPays,idEquipe) VALUES ({@j.Nom},{@j.Prenom},{@j.Pseudonyme},{@j.DateNaissance},{@j.Salaire},{@j.IdPays},{@j.IdEquipe})";
            _context.Database.ExecuteSqlInterpolated(query);
        }
    }
}

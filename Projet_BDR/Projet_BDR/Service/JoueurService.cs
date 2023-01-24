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
        public Joueur GetById(Int16 id)
        {
            FormattableString query = $"SELECT * FROM joueur WHERE id = {id}";
            return _context.Joueur.FromSqlInterpolated(query).ToArray()[0];
        }

        public void Add(Joueur j)
        {
            FormattableString query;
            if(j.IdEquipe == 0) 
            {
                query = $"INSERT INTO joueur (nom,prenom,pseudonyme,dateNaissance,salaire,idPays) VALUES ({@j.Nom},{@j.Prenom},{@j.Pseudonyme},{@j.DateNaissance},{@j.Salaire},{@j.IdPays})";
            }
            else
            {
                query = $"INSERT INTO joueur (nom,prenom,pseudonyme,dateNaissance,salaire,idPays,idEquipe) VALUES ({@j.Nom},{@j.Prenom},{@j.Pseudonyme},{@j.DateNaissance},{@j.Salaire},{@j.IdPays},{j.IdEquipe})";
            }
             
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Update(Joueur j)
        {
            FormattableString query = $"UPDATE joueur SET nom = {j.Nom}, prenom = {j.Prenom}, pseudonyme = {j.Pseudonyme}, datenaissance = {j.DateNaissance}, salaire = {j.Salaire}, idpays = {j.IdPays}, idequipe = {j.IdEquipe}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
        public void Delete(Int16 id) 
        {
            FormattableString query = $"DELETE FROM joueur WHERE id = {id}";
            _context.Database.ExecuteSqlInterpolated(query);
        }
    }
}

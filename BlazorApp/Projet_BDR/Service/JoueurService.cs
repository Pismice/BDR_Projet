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

        public VJoueurAgent[]? GetVJoueurAgent(Int16 id)
        {
            FormattableString query = $"SELECT * FROM vjoueuragent WHERE idjoueur = {id} ORDER BY nombrefoisjouer DESC, idagent ASC";
            return _context.VJoueurAgent.FromSqlInterpolated(query).ToArray();
        }

        public VJoueurStat GetVJoueurStat(Int16 id)
        {
            FormattableString query = $"SELECT * FROM vjoueurstat WHERE id = {id}";
            VJoueurStat[] vjs = _context.VJoueurStat.FromSqlInterpolated(query).ToArray();
            if(vjs.Length == 0)
            {
                return null;
            }
            return vjs[0];
        }

        public VJoueurStat[]? GetAllVJoueurStats(String filter)
        {
            FormattableString query;
            switch (filter)
            {
                case "nombrekill":
                    query = $"SELECT * FROM vjoueurstat ORDER BY nombrekill DESC";
                    break;
                case "nombremort":
                    query = $"SELECT * FROM vjoueurstat ORDER BY nombremort DESC";
                    break;
                case "nombremanchejouer":
                    query = $"SELECT * FROM vjoueurstat ORDER BY nombremanchejouer DESC";
                    break;
                case "nombremanchegagnee":
                    query = $"SELECT * FROM vjoueurstat ORDER BY nombremanchegagnee DESC";
                    break;
                default:
                    query = $"SELECT * FROM vjoueurstat";
                    break;
            }
            return _context.VJoueurStat.FromSqlInterpolated(query).ToArray();
        }
    }
}

﻿using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Projet_BDR.Data
{
    [PrimaryKey(nameof(Id))]
    public class Tournoi
    {
        
        public Int16 Id { get; set; }

        [Required]
        public string Nom { get; set; }

        [Required]
        public Int64 CashPrize { get; set; }

        [Required]
        public Int64 Point { get; set; }
        [Required]
        public DateOnly DateDebut { get; set; }
        [Required]
        public DateOnly DateFin { get; set; }
    }
}

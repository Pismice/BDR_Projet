const Chance = require("chance");
const chance = new Chance();

const express = require("express");
const app = express();

// Attention à l'ordre
app.get("/", function (req, res) {
  res.send(generatePlayers());
});
app.get("/test", function (req, res) {
  res.send("Hello DAI test");
});
app.get("/api", function (req, res) {
  res.send("Le routing est surement pas bon !");
});

app.listen(3000, function () {
  console.log("app listening on port 3000");
});

function generatePlayers() {
  const maxSalaire = 2000;
  const minSalaire = 0;
  const nbPays = 7;
  const nbEquipes = 10 * 3; // 30
  const nbJoueursParEquipe = 5;

  const queries = [];
  for (let i = 0; i < nbEquipes; i++) {
    for (let j = 0; j < nbJoueursParEquipe; j++) {
      let query;
      query = "INSERT INTO Joueur (nom, prenom, pseudonyme, dateNaissance, salaire, idPays, idEquipe) VALUES(";
      const nom = chance.last();
      const prenom = chance.first();
      const pseudonyme = chance.word();
      const raw_birthday = chance.birthday();
      const day = parseInt(raw_birthday.getDay()) + 1;
      const month = parseInt(raw_birthday.getMonth()) + 1;
      const birthday = raw_birthday.getFullYear() + '-' + month + '-' + day;
      const salaire = chance.integer({ min: 1, max: 2000 });
      const idPays = chance.integer({ min: 1, max: nbPays })
      const idEquipe = i + 1;

      query += "'" + nom + "',";
      query += "'" + prenom + "',";
      query += "'" + pseudonyme + "',";
      query += "'" + birthday + "',";
      query += salaire + ",";
      query += idPays + ",";
      query += idEquipe + ");";

      queries.push(query);
    }
  }
  console.log(queries);
  return queries;
}

DROP TABLE IF EXISTS "votacoes";

CREATE TABLE IF NOT EXISTS "votacoes" (     
    "id_proposicao" INTEGER REFERENCES "proposicoes" ("id_proposicao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    PRIMARY KEY ("id_proposicao", "id_votacao")
);

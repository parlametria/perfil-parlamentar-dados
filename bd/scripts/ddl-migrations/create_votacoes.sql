DROP TABLE IF EXISTS "votacoes";

CREATE TABLE IF NOT EXISTS "votacoes" (     
    "id_proposicao" INTEGER REFERENCES "proposicoes" ("id_proposicao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_votacao" INTEGER UNIQUE,
    "objeto_votacao" VARCHAR,
    "horario" TIMESTAMP,
    "codigo_sessao" INTEGER,
    PRIMARY KEY ("id_votacao")
);

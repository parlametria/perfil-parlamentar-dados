DROP TABLE IF EXISTS "orientacoes";

CREATE TABLE IF NOT EXISTS "orientacoes" (     
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "partido" VARCHAR,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "partido")
);

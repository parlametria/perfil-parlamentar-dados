DROP TABLE IF EXISTS "votacoes";

CREATE TABLE IF NOT EXISTS "votacoes" (     
    "id_votacao" INTEGER REFERENCES "proposicoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "id_parlamentar_voz")
);

DROP TABLE IF EXISTS "votos";

CREATE TABLE IF NOT EXISTS "votos" (     
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "id_parlamentar_voz")
);
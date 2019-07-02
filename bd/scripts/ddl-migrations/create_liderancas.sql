DROP TABLE IF EXISTS "liderancas";

CREATE TABLE IF NOT EXISTS "liderancas" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "cargo" VARCHAR(40),
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    PRIMARY KEY("id_parlamentar_voz", "id_partido")
);

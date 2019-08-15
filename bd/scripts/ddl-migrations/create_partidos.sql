DROP TABLE IF EXISTS partido;

CREATE TABLE IF NOT EXISTS "partidos" (    
    "id_partido" INTEGER,
    "sigla" VARCHAR(255),
    "tipo" VARCHAR(90),
    "situacao" VARCHAR(60),
    PRIMARY KEY("id_partido")
);
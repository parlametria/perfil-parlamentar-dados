DROP TABLE IF EXISTS partido;

CREATE TABLE IF NOT EXISTS "partido" (    
    "id" INTEGER,
    "sigla" VARCHAR(40),
    "tipo" VARCHAR(90),
    "situacao" VARCHAR(60),
    PRIMARY KEY("id")
);

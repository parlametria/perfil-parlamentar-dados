DROP TABLE IF EXISTS "temas";

CREATE TABLE IF NOT EXISTS "temas" (
    "id_tema" INTEGER, 
    "tema" VARCHAR(255),
    "slug" VARCHAR(255),
    "ativo" BOOLEAN,
    PRIMARY KEY ("id_tema"));
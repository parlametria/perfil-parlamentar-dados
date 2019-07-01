DROP TABLE IF EXISTS "proposicoes_temas";

CREATE TABLE IF NOT EXISTS "proposicoes_temas" (
    "id_proposicao" INTEGER REFERENCES "proposicoes" ("id_proposicao") ON DELETE SET NULL ON UPDATE CASCADE,    
    "id_tema" INTEGER REFERENCES "temas" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    PRIMARY KEY ("id_proposicao", "id_tema")
);

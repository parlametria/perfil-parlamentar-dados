DROP TABLE IF EXISTS investimento_partidario;

CREATE TABLE IF NOT EXISTS "investimento_partidario" (    
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "uf" VARCHAR(20),
    "esfera" VARCHAR(40),
    "valor" NUMERIC(15, 2),
    PRIMARY KEY("id_partido", "uf", "esfera")
);
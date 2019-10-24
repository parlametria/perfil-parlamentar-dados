DROP TABLE IF EXISTS investimento_partidario;

CREATE TABLE IF NOT EXISTS "investimento_partidario" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido_atual" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido_eleicao" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "total_receita_partido" NUMERIC(15, 2),
    "total_receita_candidato" NUMERIC(15, 2),
    "indice_investimento_partido" REAL,        
    PRIMARY KEY("id_parlamentar_voz")
);
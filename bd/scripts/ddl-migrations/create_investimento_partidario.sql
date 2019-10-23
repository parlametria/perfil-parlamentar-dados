DROP TABLE IF EXISTS investimento_partidario;

CREATE TABLE IF NOT EXISTS "investimento_partidario" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "total_receita_partido" REAL,
    "total_receita_candidato" REAL,
    "indice_investimento_partido" REAL,        
    PRIMARY KEY("id_parlamentar_voz")
);
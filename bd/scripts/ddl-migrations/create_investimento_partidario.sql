DROP TABLE IF EXISTS investimento_partidario;

CREATE TABLE IF NOT EXISTS "investimento_partidario" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "total_recebido" REAL,
    "indice_investimento" REAL,        
    PRIMARY KEY("id_parlamentar_voz")
);
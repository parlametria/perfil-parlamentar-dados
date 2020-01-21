DROP TABLE IF EXISTS "perfil_mais";

CREATE TABLE IF NOT EXISTS "perfil_mais" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "indice_vinculo_economico_agro" REAL,
    "indice_ativismo_ambiental" REAL,
    "peso_politico" REAL,        
    PRIMARY KEY("id_parlamentar_voz")
);
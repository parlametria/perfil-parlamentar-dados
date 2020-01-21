DROP TABLE IF EXISTS empresas_parlamentares;

CREATE TABLE IF NOT EXISTS "empresas_parlamentares" (    
    "cnpj" VARCHAR(14) REFERENCES "empresas" ("cnpj") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "data_entrada_sociedade" DATE,
    PRIMARY KEY("cnpj", "id_parlamentar_voz")
);
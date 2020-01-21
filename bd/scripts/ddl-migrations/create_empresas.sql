DROP TABLE IF EXISTS empresas;

CREATE TABLE IF NOT EXISTS "empresas" (    
    "cnpj" VARCHAR(14),
    "razao_social" VARCHAR(255),
    PRIMARY KEY("cnpj")
);
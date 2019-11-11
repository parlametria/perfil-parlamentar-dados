DROP TABLE IF EXISTS atividades_economicas_empresas;

CREATE TABLE IF NOT EXISTS "atividades_economicas_empresas" (    
    "cnpj" VARCHAR(14) REFERENCES "empresas" ("cnpj") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_atividade_economica" INTEGER REFERENCES "atividades_economicas" ("id_atividade_economica") ON DELETE SET NULL ON UPDATE CASCADE,
    "cnae_tipo" VARCHAR(50),
    PRIMARY KEY("cnpj", "id_atividade_economica", "cnae_tipo")
);
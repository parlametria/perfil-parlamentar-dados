DROP TABLE IF EXISTS "ligacoes_economicas";

CREATE TABLE IF NOT EXISTS "ligacoes_economicas" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_atividade_economica" INTEGER REFERENCES "atividades_economicas" ("id_atividade_economica") ON DELETE SET NULL ON UPDATE CASCADE,
    "total_por_atividade" NUMERIC(15, 2),
    "proporcao_doacao" REAL,
    "indice_ligacao_atividade_economica" REAL,        
    PRIMARY KEY("id_parlamentar_voz", "id_atividade_economica")
);

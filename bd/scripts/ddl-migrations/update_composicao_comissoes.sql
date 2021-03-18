DROP TABLE IF EXISTS composicao_comissoes;

CREATE TABLE IF NOT EXISTS "composicao_comissoes" (
    "id_comissao_voz" VARCHAR(40) REFERENCES "comissoes" ("id_comissao_voz") ON DELETE CASCADE ON UPDATE CASCADE, 
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_periodo" VARCHAR(40),
    "cargo" VARCHAR(40),
    "situacao" VARCHAR(40),
    "data_inicio" DATE,
    "data_fim" DATE,
    "is_membro_atual" BOOLEAN,
    PRIMARY KEY("id_comissao_voz", "id_parlamentar_voz", "id_periodo")
);

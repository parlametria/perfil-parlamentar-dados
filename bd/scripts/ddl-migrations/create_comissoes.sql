DROP TABLE IF EXISTS composicao_comissoes;
DROP TABLE IF EXISTS comissoes;

CREATE TABLE IF NOT EXISTS "comissoes" (
    "id_comissao_voz" VARCHAR(40),
    "id" INTEGER,
    "casa" VARCHAR(10),
    "sigla" VARCHAR(40),
    "nome" VARCHAR(255),
    PRIMARY KEY ("id_comissao_voz")
);

CREATE TABLE IF NOT EXISTS "composicao_comissoes" (
    "id_comissao_voz" VARCHAR(40) REFERENCES "comissoes" ("id_comissao_voz") ON DELETE CASCADE ON UPDATE CASCADE, 
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "cargo" VARCHAR(40),
    "situacao" VARCHAR(40),
    PRIMARY KEY("id_comissao_voz", "id_parlamentar_voz")
);

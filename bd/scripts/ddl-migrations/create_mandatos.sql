DROP TABLE IF EXISTS "mandatos";

CREATE TABLE IF NOT EXISTS "mandatos" (
    "id_mandato_voz" VARCHAR(40),
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_legislatura" INTEGER,
    "data_inicio" DATE,
    "data_fim" DATE,
    "situacao" VARCHAR(255),
    "cod_causa_fim_exercicio" INTEGER,
    "desc_causa_fim_exercicio" VARCHAR(255),
    PRIMARY KEY ("id_mandato_voz")
);

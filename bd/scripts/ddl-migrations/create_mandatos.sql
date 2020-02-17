DROP TABLE IF EXISTS "mandatos";

CREATE TABLE IF NOT EXISTS "mandatos" (
    "id_mandato_voz" VARCHAR(40),
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "ano_eleicao" INTEGER,
    "num_turno" INTEGER,
    "cargo" VARCHAR(20),
    "unidade_eleitoral" VARCHAR(30),
    "uf_eleitoral" VARCHAR(2),
    "situacao_candidatura" VARCHAR(30),
    "situacao_totalizacao_turno" VARCHAR(50),
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "votos" INTEGER,
    PRIMARY KEY ("id_mandato_voz")
);

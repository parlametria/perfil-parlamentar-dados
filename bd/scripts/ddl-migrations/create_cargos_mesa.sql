DROP TABLE IF EXISTS cargos_mesa;

CREATE TABLE IF NOT EXISTS "cargos_mesa" (
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "casa" VARCHAR(10),
    "cargo" VARCHAR(255),
    "data_inicio" DATE,
    "data_fim" DATE,
    "legislatura" INTEGER,
    PRIMARY KEY("id_parlamentar_voz", "cargo", "legislatura")
);

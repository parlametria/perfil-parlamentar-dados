DROP TABLE IF EXISTS cargos_mesa;

CREATE TABLE IF NOT EXISTS "cargos_mesa" (
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "casa" VARCHAR(10),
    "cargo" VARCHAR(255),
    PRIMARY KEY("id_parlamentar_voz")
);

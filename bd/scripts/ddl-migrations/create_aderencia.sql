DROP TABLE IF EXISTS aderencia;

CREATE TABLE IF NOT EXISTS "aderencia" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido" INTEGER REFERENCES "partido" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    "faltou" INTEGER,
    "partido_liberou" INTEGER,
    "nao_seguiu" INTEGER,
    "seguiu" INTEGER,
    "aderencia" REAL,
    PRIMARY KEY("id_parlamentar_voz", "id_partido")
);

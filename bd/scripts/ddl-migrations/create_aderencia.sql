DROP TABLE IF EXISTS aderencia;

CREATE TABLE IF NOT EXISTS "aderencias" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_tema" INTEGER REFERENCES "temas" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    "faltou" INTEGER,
    "partido_liberou" INTEGER,
    "nao_seguiu" INTEGER,
    "seguiu" INTEGER,
    "aderencia" REAL,
    PRIMARY KEY("id_parlamentar_voz", "id_partido", "id_tema")
);

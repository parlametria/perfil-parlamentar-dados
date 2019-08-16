-- ADERENCIA DOS PARLAMENTARES
BEGIN;
CREATE TEMP TABLE temp_aderencia AS SELECT * FROM aderencias LIMIT 0;

\copy temp_aderencia FROM './data/aderencia.csv' DELIMITER ',' CSV HEADER;

INSERT INTO aderencias (id_parlamentar_voz, id_partido, id_tema, faltou, partido_liberou, nao_seguiu, seguiu, aderencia)
SELECT id_parlamentar_voz, id_partido, id_tema, faltou, partido_liberou, nao_seguiu, seguiu, aderencia
FROM temp_aderencia
ON CONFLICT (id_parlamentar_voz, id_partido, id_tema)
DO
  UPDATE
  SET 
    faltou = EXCLUDED.faltou,
    partido_liberou = EXCLUDED.partido_liberou,
    nao_seguiu = EXCLUDED.nao_seguiu,
    seguiu = EXCLUDED.seguiu,    
    aderencia = EXCLUDED.aderencia;

DELETE FROM aderencias
WHERE (id_parlamentar_voz, id_partido, id_tema) NOT IN
  (SELECT id_parlamentar_voz, id_partido, id_tema
   FROM temp_aderencia); 

DROP TABLE temp_aderencia;
COMMIT;
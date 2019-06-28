-- ADERENCIA DOS PARLAMENTARES
CREATE TEMP TABLE temp_aderencia AS SELECT * FROM aderencia LIMIT 0;

\copy temp_aderencia FROM './data/aderencia.csv' DELIMITER ',' CSV HEADER;

INSERT INTO aderencia (id_parlamentar_voz, id_partido, faltou, partido_liberou, nao_seguiu, seguiu, aderencia)
SELECT id_parlamentar_voz, id_partido, faltou, partido_liberou, nao_seguiu, seguiu, aderencia
FROM temp_aderencia
ON CONFLICT (id_parlamentar_voz, id_partido) 
DO
  UPDATE
  SET 
    faltou = EXCLUDED.faltou,
    partido_liberou = EXCLUDED.partido_liberou,
    nao_seguiu = EXCLUDED.nao_seguiu,
    seguiu = EXCLUDED.seguiu,    
    aderencia = EXCLUDED.aderencia;

DELETE FROM aderencia
WHERE (id_parlamentar_voz, id_partido) NOT IN
  (SELECT id_parlamentar_voz, id_partido
   FROM temp_aderencia); 

DROP TABLE temp_aderencia;
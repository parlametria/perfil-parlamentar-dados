-- LIDERANÇAS
BEGIN;

CREATE TEMP TABLE temp_liderancas AS SELECT * FROM liderancas LIMIT 0;

\copy temp_liderancas FROM './data/liderancas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER; 

INSERT INTO liderancas (id_parlamentar_voz, id_partido, cargo)
SELECT id_parlamentar_voz, id_partido, cargo
FROM temp_liderancas
ON CONFLICT (id_parlamentar_voz, id_partido) 
DO
  UPDATE
  SET 
    cargo = EXCLUDED.cargo;

DELETE FROM liderancas
WHERE (id_parlamentar_voz, id_partido) NOT IN
  (SELECT id_parlamentar_voz, id_partido
   FROM temp_liderancas); 

DROP TABLE temp_liderancas;

COMMIT;
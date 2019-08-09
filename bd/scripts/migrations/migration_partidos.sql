-- PARTIDOS POLITICOS
BEGIN;
CREATE TEMP TABLE temp_partido AS SELECT * FROM partidos LIMIT 0;

\copy temp_partido FROM './data/partidos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO partidos (id_partido, sigla, tipo, situacao)
SELECT id_partido, sigla, tipo, situacao
FROM temp_partido
ON CONFLICT (id_partido) 
DO
  UPDATE
  SET 
    sigla = EXCLUDED.sigla,
    tipo = EXCLUDED.tipo,
    situacao = EXCLUDED.situacao;

DELETE FROM partidos
WHERE (id_partido, sigla, tipo, situacao) NOT IN
  (SELECT id_partido, sigla, tipo, situacao
   FROM temp_partido); 

DROP TABLE temp_partido;
COMMIT;
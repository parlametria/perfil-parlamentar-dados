-- PARTIDOS POLITICOS
CREATE TEMP TABLE temp_partido AS SELECT * FROM partido LIMIT 0;

\copy temp_partido FROM './data/partidos.csv' DELIMITER ',' CSV HEADER;

INSERT INTO partido (id, sigla, situacao)
SELECT id, sigla, situacao
FROM temp_partido
ON CONFLICT (id) 
DO
  UPDATE
  SET 
    sigla = EXCLUDED.sigla,
    situacao = EXCLUDED.situacao;

DELETE FROM partido
WHERE (id, sigla, situacao) NOT IN
  (SELECT id, sigla, situacao
   FROM temp_partido); 

DROP TABLE temp_partido;
-- PARTIDOS POLITICOS
CREATE TEMP TABLE temp_partido AS SELECT * FROM partido LIMIT 0;

\copy temp_partido FROM './data/partidos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO partido (id, sigla, tipo, situacao)
SELECT id, sigla, tipo, situacao
FROM temp_partido
ON CONFLICT (id) 
DO
  UPDATE
  SET 
    sigla = EXCLUDED.sigla,
    tipo = EXCLUDED.tipo,
    situacao = EXCLUDED.situacao;

DELETE FROM partido
WHERE (id, sigla, tipo, situacao) NOT IN
  (SELECT id, sigla, tipo, situacao
   FROM temp_partido); 

DROP TABLE temp_partido;
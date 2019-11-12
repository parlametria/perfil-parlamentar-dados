-- EMPRESAS
BEGIN;
CREATE TEMP TABLE temp_empresas AS SELECT * FROM empresas LIMIT 0;

\copy temp_empresas FROM './data/empresas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO empresas (cnpj, razao_social)
SELECT cnpj, razao_social
FROM temp_empresas
ON CONFLICT (cnpj) 
DO
  UPDATE
  SET 
    razao_social = EXCLUDED.razao_social;

DELETE FROM empresas
WHERE (cnpj) NOT IN
  (SELECT cnpj
   FROM temp_empresas); 

DROP TABLE temp_empresas;
COMMIT;
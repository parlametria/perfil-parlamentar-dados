-- EMPRESAS DE PARLAMENTARES
BEGIN;
CREATE TEMP TABLE temp_empresas_parlamentares AS SELECT * FROM empresas_parlamentares LIMIT 0;

\copy temp_empresas_parlamentares FROM './data/empresas_parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO empresas_parlamentares (cnpj, id_parlamentar_voz, data_entrada_sociedade)
SELECT cnpj, id_parlamentar_voz, data_entrada_sociedade
FROM temp_empresas_parlamentares
ON CONFLICT (cnpj, id_parlamentar_voz) 
DO
  UPDATE
  SET 
    data_entrada_sociedade = EXCLUDED.data_entrada_sociedade;

DELETE FROM empresas_parlamentares
WHERE (cnpj, id_parlamentar_voz) NOT IN
  (SELECT cnpj, id_parlamentar_voz
   FROM temp_empresas_parlamentares); 

DROP TABLE temp_empresas_parlamentares;
COMMIT;
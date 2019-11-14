-- EMPRESAS
BEGIN;
CREATE TEMP TABLE temp_atividades_economicas_empresas AS SELECT * FROM atividades_economicas_empresas LIMIT 0;

\copy temp_atividades_economicas_empresas FROM './data/atividades_economicas_empresas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO atividades_economicas_empresas (cnpj, id_atividade_economica, cnae_tipo)
SELECT cnpj, id_atividade_economica, cnae_tipo
FROM temp_atividades_economicas_empresas
ON CONFLICT (cnpj, id_atividade_economica, cnae_tipo) 
DO NOTHING;

DELETE FROM atividades_economicas_empresas
WHERE (cnpj, id_atividade_economica, cnae_tipo) NOT IN
  (SELECT cnpj, id_atividade_economica, cnae_tipo
   FROM temp_atividades_economicas_empresas); 

DROP TABLE temp_atividades_economicas_empresas;
COMMIT;
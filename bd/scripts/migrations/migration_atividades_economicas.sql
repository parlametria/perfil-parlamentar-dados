-- ATIVIDADES ECONÔMICAS
BEGIN;
CREATE TEMP TABLE temp_atividades_economicas AS SELECT * FROM atividades_economicas LIMIT 0;

\copy temp_atividades_economicas FROM './data/atividades_economicas.csv' DELIMITER ',' CSV HEADER;

INSERT INTO atividades_economicas (id_atividade_economica, nome)
SELECT id_atividade_economica, nome
FROM temp_atividades_economicas
ON CONFLICT (id_atividade_economica)
DO
  UPDATE
  SET 
    nome = EXCLUDED.nome;

DELETE FROM atividades_economicas
WHERE (id_atividade_economica) NOT IN
  (SELECT id_atividade_economica
   FROM temp_atividades_economicas); 

DROP TABLE temp_atividades_economicas;
COMMIT;
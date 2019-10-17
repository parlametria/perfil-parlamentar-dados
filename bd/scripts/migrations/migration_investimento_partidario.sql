-- INVESTIMENTO PARTIDARIO
BEGIN;
CREATE TEMP TABLE temp_investimento_partidario AS SELECT * FROM investimento_partidario LIMIT 0;

\copy temp_investimento_partidario FROM './data/investimento_partidario.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO investimento_partidario (id_parlamentar_voz, total_recebido, indice_investimento)
SELECT id_parlamentar_voz, total_recebido, indice_investimento
FROM temp_investimento_partidario
ON CONFLICT (id_parlamentar_voz) 
DO
  UPDATE
  SET 
    total_recebido = EXCLUDED.total_recebido,
    indice_investimento = EXCLUDED.indice_investimento;

DELETE FROM investimento_partidario
WHERE (id_parlamentar_voz) NOT IN
  (SELECT id_parlamentar_voz
   FROM temp_investimento_partidario); 

DROP TABLE temp_investimento_partidario;
COMMIT;
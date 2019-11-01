-- DOACOES PARTIDO
BEGIN;
CREATE TEMP TABLE temp_investimento_partidario AS SELECT * FROM investimento_partidario LIMIT 0;

\copy temp_investimento_partidario FROM './data/investimento_partidario.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO investimento_partidario (id_partido, uf, esfera, valor)
SELECT id_partido, uf, esfera, valor
FROM temp_investimento_partidario
ON CONFLICT (id_partido, uf, esfera) 
DO
  UPDATE
  SET 
    valor = EXCLUDED.valor;

DELETE FROM investimento_partidario
WHERE (id_partido, uf, esfera) NOT IN
  (SELECT id_parlamentar_voz, uf, esfera
   FROM temp_investimento_partidario); 

DROP TABLE temp_investimento_partidario;
COMMIT;

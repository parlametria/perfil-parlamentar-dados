-- INVESTIMENTO PARTIDARIO
BEGIN;
CREATE TEMP TABLE temp_investimento_partidario AS SELECT * FROM investimento_partidario LIMIT 0;

\copy temp_investimento_partidario FROM './data/investimento_partidario.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO investimento_partidario (id_parlamentar_voz, id_partido_atual, id_partido_eleicao, total_receita_partido, total_receita_candidato, indice_investimento_partido)
SELECT id_parlamentar_voz, id_partido_atual, id_partido_eleicao, total_receita_partido, total_receita_candidato, indice_investimento_partido
FROM temp_investimento_partidario
ON CONFLICT (id_parlamentar_voz) 
DO
  UPDATE
  SET 
    id_partido_atual = EXCLUDED.id_partido_atual,
    id_partido_eleicao = EXCLUDED.id_partido_eleicao,
    total_receita_partido = EXCLUDED.total_receita_partido,
    total_receita_candidato = EXCLUDED.total_receita_candidato,
    indice_investimento_partido = EXCLUDED.indice_investimento_partido;

DELETE FROM investimento_partidario
WHERE (id_parlamentar_voz) NOT IN
  (SELECT id_parlamentar_voz
   FROM temp_investimento_partidario); 

DROP TABLE temp_investimento_partidario;
COMMIT;

-- LIGACOES ECONOMICAS
BEGIN;
CREATE TEMP TABLE temp_ligacoes_economicas AS SELECT * FROM ligacoes_economicas LIMIT 0;

\copy temp_ligacoes_economicas FROM './data/ligacoes_economicas.csv' DELIMITER ',' CSV HEADER;

INSERT INTO ligacoes_economicas (id_parlamentar_voz, id_atividade_economica, total_por_atividade, proporcao_doacao, indice_ligacao_atividade_economica)
SELECT id_parlamentar_voz, id_atividade_economica, total_por_atividade, proporcao_doacao, indice_ligacao_atividade_economica
FROM temp_ligacoes_economicas
ON CONFLICT (id_parlamentar_voz, id_atividade_economica)
DO
  UPDATE
  SET
    total_por_atividade = EXCLUDED.total_por_atividade,
    proporcao_doacao = EXCLUDED.proporcao_doacao,    
    indice_ligacao_atividade_economica = EXCLUDED.indice_ligacao_atividade_economica;

DELETE FROM ligacoes_economicas
WHERE (id_parlamentar_voz, id_atividade_economica) NOT IN
  (SELECT id_parlamentar_voz, id_atividade_economica
   FROM temp_ligacoes_economicas);

DROP TABLE temp_ligacoes_economicas;
COMMIT;

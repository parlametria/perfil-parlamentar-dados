-- COMPOSICAO DAS COMISSOES
BEGIN;
CREATE TEMP TABLE temp_composicao_comissoes AS SELECT * FROM composicao_comissoes LIMIT 0;

\copy temp_composicao_comissoes FROM './data/composicao_comissoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO composicao_comissoes (id_comissao_voz, id_parlamentar_voz, id_periodo, cargo, situacao, data_inicio, data_fim, is_membro_atual)
SELECT id_comissao_voz, id_parlamentar_voz, id_periodo, cargo, situacao, data_inicio, data_fim, is_membro_atual
FROM temp_composicao_comissoes
ON CONFLICT (id_comissao_voz, id_parlamentar_voz, id_periodo) 
DO
  UPDATE
  SET 
    cargo = EXCLUDED.cargo,
    situacao = EXCLUDED.situacao,
    data_fim = EXCLUDED.data_fim,
    is_membro_atual = EXCLUDED.is_membro_atual;

DELETE FROM composicao_comissoes
WHERE (id_comissao_voz, id_parlamentar_voz, id_periodo) NOT IN
  (SELECT id_comissao_voz, id_parlamentar_voz, id_periodo
   FROM temp_composicao_comissoes); 

DROP TABLE temp_composicao_comissoes;
COMMIT;
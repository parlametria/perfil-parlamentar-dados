-- COMPOSICAO DAS COMISSOES
CREATE TEMP TABLE temp_composicao_comissoes AS SELECT * FROM composicao_comissoes LIMIT 0;

\copy temp_composicao_comissoes FROM './data/composicao_comissoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO composicao_comissoes (comissao_id, parlamentar_cpf, cargo, situacao)
SELECT comissao_id, parlamentar_cpf, cargo, situacao
FROM temp_composicao_comissoes
ON CONFLICT (comissao_id, parlamentar_cpf) 
DO
  UPDATE
  SET 
    cargo = EXCLUDED.cargo,
    situacao = EXCLUDED.situacao;

DROP TABLE temp_composicao_comissoes;
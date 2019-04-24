-- COMPOSICAO DAS COMISSOES
CREATE TEMP TABLE temp_composicao_comissoes AS SELECT * FROM composicao_comissoes LIMIT 0;

\copy temp_composicao_comissoes FROM './data/composicao_comissoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO composicao_comissoes (id_comissao_voz, id_parlamentar_voz, cargo, situacao)
SELECT id_comissao_voz, id_parlamentar_voz, cargo, situacao
FROM temp_composicao_comissoes
ON CONFLICT (id_comissao_voz, id_parlamentar_voz) 
DO
  UPDATE
  SET 
    cargo = EXCLUDED.cargo,
    situacao = EXCLUDED.situacao;

DELETE FROM composicao_comissoes
WHERE (id_comissao_voz, id_parlamentar_voz) NOT IN
  (SELECT id_comissao_voz, id_parlamentar_voz
   FROM temp_composicao_comissoes); 

DROP TABLE temp_composicao_comissoes;
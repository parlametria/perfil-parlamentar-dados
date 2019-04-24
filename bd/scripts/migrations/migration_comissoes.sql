-- COMISSOES
CREATE TEMP TABLE temp_comissoes AS SELECT * FROM comissoes LIMIT 0;

\copy temp_comissoes FROM './data/comissoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO comissoes (id_comissao_voz, id, casa, sigla, nome)
SELECT id_comissao_voz, id, casa, sigla, nome
FROM temp_comissoes
ON CONFLICT (id_comissao_voz) 
DO
  UPDATE
  SET
    id = EXCLUDED.id,
    casa = EXCLUDED.casa,    
    sigla = EXCLUDED.sigla,
    nome = EXCLUDED.nome;

DELETE FROM comissoes
WHERE (id_comissao_voz) NOT IN
  (SELECT id_comissao_voz
   FROM temp_comissoes);

DROP TABLE temp_comissoes;
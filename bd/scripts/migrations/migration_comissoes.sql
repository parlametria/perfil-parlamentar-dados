-- COMISSOES
CREATE TEMP TABLE temp_comissoes AS SELECT * FROM comissoes LIMIT 0;

\copy temp_comissoes FROM './data/comissoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO comissoes (id, sigla, nome)
SELECT id, sigla, nome
FROM temp_comissoes
ON CONFLICT (id) 
DO
  UPDATE
  SET 
    sigla = EXCLUDED.sigla,
    nome = EXCLUDED.nome;

DROP TABLE temp_comissoes;
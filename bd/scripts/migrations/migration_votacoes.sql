-- VOTACOES
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes (id_proposicao, id_votacao)
SELECT id_proposicao, id_votacao
FROM temp_votacoes
ON CONFLICT (id_votacao) 
DO
  UPDATE
  SET 
    id_proposicao = EXCLUDED.id_proposicao;

DROP TABLE temp_votacoes;

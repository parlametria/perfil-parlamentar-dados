-- VOTACOES
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes (id, resposta, cpf, proposicao_id)
SELECT id, resposta, cpf, proposicao_id
FROM temp_votacoes
ON CONFLICT (cpf, proposicao_id) 
DO
  UPDATE
  SET 
    resposta = EXCLUDED.resposta;

DROP TABLE temp_votacoes;
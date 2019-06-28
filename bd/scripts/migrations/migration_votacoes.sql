-- VOTACOES
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes (id_proposicao, id_votacao)
SELECT id_proposicao, id_votacao
FROM temp_votacoes
ON CONFLICT (id_proposicao, id_votacao) 
DO NOTHING;

DELETE FROM votacoes
WHERE (id_proposicao, id_votacao) NOT IN
  (SELECT id_proposicao, id_votacao
   FROM temp_votacoes);

DROP TABLE temp_votacoes;

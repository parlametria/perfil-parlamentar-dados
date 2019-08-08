-- VOTACOES
BEGIN;
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes (id_proposicao, id_votacao, objeto_votacao, horario, codigo_sessao)
SELECT id_proposicao, id_votacao, objeto_votacao, horario, codigo_sessao
FROM temp_votacoes
ON CONFLICT (id_votacao) 
DO
  UPDATE
  SET 
    id_proposicao = EXCLUDED.id_proposicao,
    objeto_votacao = EXCLUDED.objeto_votacao,
    horario = EXCLUDED.horario,
    codigo_sessao = EXCLUDED.codigo_sessao;

DROP TABLE temp_votacoes;
COMMIT;
-- VOTACOES
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes (id_votacao, id_parlamentar_voz, voto)
SELECT id_votacao, id_parlamentar_voz, voto
FROM temp_votacoes
ON CONFLICT (id_votacao, id_parlamentar_voz) 
DO
  UPDATE
  SET 
    voto = EXCLUDED.voto;

DELETE FROM votacoes
WHERE (id_votacao, id_parlamentar_voz) NOT IN
  (SELECT id_votacao, id_parlamentar_voz
   FROM temp_votacoes);


DROP TABLE temp_votacoes;
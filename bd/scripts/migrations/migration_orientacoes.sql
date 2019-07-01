-- MANDATOS
CREATE TEMP TABLE temp_orientacoes AS SELECT * FROM orientacoes LIMIT 0;

\copy temp_orientacoes FROM './data/orientacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO orientacoes (id_votacao, partido, voto)
SELECT id_votacao, partido, voto
FROM temp_orientacoes
ON CONFLICT (id_votacao, partido) 
DO
  UPDATE
    SET 
      voto = EXCLUDED.voto;
      
DELETE FROM orientacoes
WHERE (id_votacao, partido) NOT IN
  (SELECT id_votacao, partido
   FROM temp_orientacoes);

DROP TABLE temp_orientacoes;

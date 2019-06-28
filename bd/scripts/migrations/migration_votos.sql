-- VOTOS
CREATE TEMP TABLE temp_votos AS SELECT * FROM votos LIMIT 0;

\copy temp_votos FROM './data/votos.csv' DELIMITER ',' CSV HEADER;

INSERT INTO votos (id_votacao, id_parlamentar_voz, voto)
SELECT id_votacao, id_parlamentar_voz, voto
FROM temp_votos
ON CONFLICT (id_votacao, id_parlamentar_voz) 
DO
  UPDATE
  SET 
    voto = EXCLUDED.voto;

DELETE FROM votos
WHERE (id_votacao, id_parlamentar_voz) NOT IN
  (SELECT id_votacao, id_parlamentar_voz
   FROM temp_votos);

DROP TABLE temp_votos;
-- RESPOSTAS
BEGIN;
CREATE TEMP TABLE temp_respostas AS SELECT * FROM respostas LIMIT 0;

\copy temp_respostas FROM './data/respostas.csv' DELIMITER ',' CSV HEADER;

INSERT INTO respostas (id, resposta, id_parlamentar_voz, pergunta_id)
SELECT id, resposta, id_parlamentar_voz, pergunta_id
FROM temp_respostas
ON CONFLICT (id) 
DO
  UPDATE
  SET 
  resposta = EXCLUDED.resposta,
  id_parlamentar_voz = EXCLUDED.id_parlamentar_voz,
  pergunta_id = EXCLUDED.pergunta_id;


DELETE FROM respostas
WHERE id NOT IN
  (SELECT id
   FROM temp_respostas);

DROP TABLE temp_respostas;
COMMIT;
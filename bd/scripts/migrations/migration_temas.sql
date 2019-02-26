-- TEMAS
CREATE TEMP TABLE temp_temas AS SELECT * FROM temas LIMIT 0;

\copy temp_temas FROM './data/temas.csv' DELIMITER ',' CSV HEADER;

INSERT INTO temas (tema, id) 
SELECT tema, id
FROM temp_temas
ON CONFLICT (id)
DO
  UPDATE
  SET 
    tema = EXCLUDED.tema;

DELETE FROM temas
 WHERE id NOT IN (SELECT t.id
                  FROM temp_temas t);

DROP TABLE temp_temas;
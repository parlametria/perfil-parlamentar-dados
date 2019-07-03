-- TEMAS
CREATE TEMP TABLE temp_temas AS SELECT * FROM temas LIMIT 0;

\copy temp_temas FROM './data/temas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO temas (id_tema, tema, slug, ativo) 
SELECT id_tema, tema, slug, ativo
FROM temp_temas
ON CONFLICT (id_tema)
DO
  UPDATE
  SET 
    tema = EXCLUDED.tema,
    slug = EXCLUDED.slug,
    ativo = EXCLUDED.ativo;

DELETE FROM temas
 WHERE id_tema NOT IN (SELECT t.id_tema
                  FROM temp_temas t);

DROP TABLE temp_temas;
-- PROPOSICOES
BEGIN;
CREATE TEMP TABLE temp_proposicoes_temas AS SELECT * FROM proposicoes_temas LIMIT 0;

\copy temp_proposicoes_temas FROM './data/proposicoes_temas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

-- UPSERT PROPOSICOES_TEMAS

INSERT INTO proposicoes_temas (id_proposicao, id_tema) 
SELECT id_proposicao, id_tema
FROM temp_proposicoes_temas
ON CONFLICT (id_proposicao, id_tema) 
DO NOTHING;

DROP TABLE temp_proposicoes_temas;
COMMIT;
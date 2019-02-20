-- UPSERT AND DELETE PROPOSICOES

CREATE TEMP TABLE temp_proposicoes AS SELECT * FROM proposicoes LIMIT 0;

\copy temp_proposicoes FROM './data/proposicoes_alt.csv' DELIMITER ',' CSV HEADER;

INSERT INTO proposicoes (projeto_lei, id_votacao, titulo, descricao, tema_id) 
SELECT projeto_lei, id_votacao, titulo, descricao, tema_id
FROM temp_proposicoes
ON CONFLICT (id_votacao) 
DO
 UPDATE
  SET 
    projeto_lei = EXCLUDED.projeto_lei,
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    tema_id = EXCLUDED.tema_id;

DELETE FROM proposicoes
 WHERE id_votacao NOT IN (SELECT p.id_votacao 
                          FROM temp_proposicoes p);

DROP TABLE temp_proposicoes;

-- UPSERT AND DELETE TEMAS

CREATE TEMP TABLE temp_temas AS SELECT * FROM temas LIMIT 0;

\copy temp_temas FROM './data/temas_alt.csv' DELIMITER ',' CSV HEADER;

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

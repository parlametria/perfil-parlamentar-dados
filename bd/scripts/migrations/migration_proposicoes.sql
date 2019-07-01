-- PROPOSICOES
CREATE TEMP TABLE temp_proposicoes AS SELECT * FROM proposicoes LIMIT 0;

\copy temp_proposicoes FROM './data/proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

-- UPSERT PROPOSICOES

INSERT INTO proposicoes (id_proposicao, casa, projeto_lei, titulo, descricao, status_proposicao, status_importante) 
SELECT id_proposicao, casa, projeto_lei, titulo, descricao, status_proposicao, status_importante
FROM temp_proposicoes
ON CONFLICT (id_proposicao) 
DO
  UPDATE
  SET 
    casa = EXCLUDED.casa,    
    projeto_lei = EXCLUDED.projeto_lei,
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status_proposicao = EXCLUDED.status_proposicao,
    status_importante = EXCLUDED.status_importante;    

DROP TABLE temp_proposicoes;
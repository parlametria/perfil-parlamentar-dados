-- PROPOSICOES
CREATE TEMP TABLE temp_proposicoes AS SELECT * FROM proposicoes LIMIT 0;

\copy temp_proposicoes FROM './data/proposicoes.csv' DELIMITER ',' CSV HEADER;

-- UPSERT PROPOSICOES

INSERT INTO proposicoes (projeto_lei, id_votacao, titulo, descricao, tema_id, status_proposicao, id_proposicao) 
SELECT projeto_lei, id_votacao, titulo, descricao, tema_id, status_proposicao, id_proposicao
FROM temp_proposicoes
ON CONFLICT (id_votacao) 
DO
  UPDATE
  SET 
    projeto_lei = EXCLUDED.projeto_lei,    
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    tema_id = EXCLUDED.tema_id,
    status_proposicao = EXCLUDED.status_proposicao,
    id_proposicao = EXCLUDED.id_proposicao;


UPDATE proposicoes
SET status_proposicao = 'Ativa'
WHERE id_votacao IN (SELECT p.id_votacao
                     FROM temp_proposicoes p
                     WHERE p.status_proposicao = 'Ativa');

UPDATE proposicoes
SET status_proposicao = 'Inativa'
WHERE id_votacao NOT IN (SELECT p.id_votacao
                     FROM temp_proposicoes p
                     WHERE p.status_proposicao = 'Ativa');                     


DROP TABLE temp_proposicoes;

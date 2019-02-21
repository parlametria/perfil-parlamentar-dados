-- CREATE TEMP TABLES

-- PROPOSICOES
CREATE TEMP TABLE temp_proposicoes AS SELECT * FROM proposicoes LIMIT 0;

\copy temp_proposicoes FROM './data/proposicoes_alt.csv' DELIMITER ',' CSV HEADER;

-- VOTACOES
CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes_alt.csv' DELIMITER ',' CSV HEADER;

-- TEMAS
CREATE TEMP TABLE temp_temas AS SELECT * FROM temas LIMIT 0;

\copy temp_temas FROM './data/temas_alt.csv' DELIMITER ',' CSV HEADER;


-- UPSERT AND DELETE VOTACOES

INSERT INTO votacoes (id, resposta, cpf, proposicao_id)
SELECT id, resposta, cpf, proposicao_id
FROM temp_votacoes
ON CONFLICT (cpf, proposicao_id) 
DO
 UPDATE
  SET 
    resposta = EXCLUDED.resposta;

DELETE FROM votacoes
WHERE proposicao_id NOT IN (SELECT p.id_votacao
                            FROM temp_proposicoes p);


-- UPSERT AND DELETE PROPOSICOES

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


-- UPSERT AND DELETE TEMAS

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


-- DROP TABLES

DROP TABLE temp_proposicoes;
DROP TABLE temp_temas;
DROP TABLE temp_votacoes;

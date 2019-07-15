-- PARLAMENTARES
CREATE TEMP TABLE temp_parlamentares AS SELECT * FROM parlamentares LIMIT 0;

\copy temp_parlamentares FROM './data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO parlamentares (id_parlamentar_voz, id_parlamentar, casa, cpf, nome_civil, 
  nome_eleitoral, genero, uf, id_partido, situacao, condicao_eleitoral, ultima_legislatura, em_exercicio) 
SELECT id_parlamentar_voz, id_parlamentar, casa, cpf, nome_civil, 
  nome_eleitoral, genero, uf, id_partido, situacao, condicao_eleitoral, ultima_legislatura, em_exercicio
FROM temp_parlamentares
ON CONFLICT (id_parlamentar_voz)
DO
  UPDATE
  SET 
    nome_civil = EXCLUDED.nome_civil,
    nome_eleitoral = EXCLUDED.nome_eleitoral,
    genero = EXCLUDED.genero,
    uf = EXCLUDED.uf,
    id_partido = EXCLUDED.id_partido,
    situacao = EXCLUDED.situacao,
    condicao_eleitoral = EXCLUDED.condicao_eleitoral,
    ultima_legislatura = EXCLUDED.ultima_legislatura,
    em_exercicio = EXCLUDED.em_exercicio;

DELETE FROM parlamentares
 WHERE id_parlamentar_voz NOT IN 
 (SELECT id_parlamentar_voz FROM temp_parlamentares);

DROP TABLE temp_parlamentares;
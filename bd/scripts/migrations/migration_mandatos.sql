-- MANDATOS
CREATE TEMP TABLE temp_mandatos AS SELECT * FROM mandatos LIMIT 0;

\copy temp_mandatos FROM './data/mandatos.csv' DELIMITER ',' CSV HEADER;

INSERT INTO mandatos (id_parlamentar_voz, id_legislatura, data_inicio, 
  data_fim, situacao, cod_causa_fim_exercicio, desc_causa_fim_exercicio)

SELECT id_parlamentar_voz, id_legislatura, data_inicio, 
data_fim, situacao, cod_causa_fim_exercicio, desc_causa_fim_exercicio
FROM temp_mandatos
ON CONFLICT (id_parlamentar_voz, id_legislatura) 
DO
  DELETE FROM mandatos 
    WHERE id_parlamentar_voz = EXCLUDED.id_parlamentar_voz AND id_legislatura = EXCLUDED.id_legislatura;

DROP TABLE temp_mandatos; 
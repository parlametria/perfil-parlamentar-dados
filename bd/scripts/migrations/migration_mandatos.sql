-- MANDATOS
BEGIN;
CREATE TEMP TABLE temp_mandatos AS SELECT * FROM mandatos LIMIT 0;

\copy temp_mandatos FROM './data/mandatos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO mandatos
SELECT *
FROM temp_mandatos
ON CONFLICT (id_mandato_voz) 
DO
  UPDATE
    SET 
      id_parlamentar_voz = EXCLUDED.id_parlamentar_voz,
      ano_eleicao = EXCLUDED.ano_eleicao,
      num_turno = EXCLUDED.num_turno,
      cargo = EXCLUDED.cargo,
      unidade_eleitoral = EXCLUDED.unidade_eleitoral,
      uf_eleitoral = EXCLUDED.uf_eleitoral,
      situacao_candidatura = EXCLUDED.situacao_candidatura,
      situacao_totalizacao_turno = EXCLUDED.situacao_totalizacao_turno,
      id_partido = EXCLUDED.id_partido,
      votos = EXCLUDED.votos;
      
DELETE FROM mandatos
WHERE (id_mandato_voz) NOT IN
  (SELECT id_mandato_voz
   FROM temp_mandatos);

DROP TABLE temp_mandatos; 
COMMIT;

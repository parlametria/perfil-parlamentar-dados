-- CARGOS EM MESA DIRETORA
BEGIN;
CREATE TEMP TABLE temp_cargos_mesa AS SELECT * FROM cargos_mesa LIMIT 0;

\copy temp_cargos_mesa FROM './data/cargos_mesa.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO cargos_mesa (id_parlamentar_voz, casa, cargo, data_inicio, data_fim, legislatura)
SELECT id_parlamentar_voz, casa, cargo, data_inicio, data_fim, legislatura
FROM temp_cargos_mesa
ON CONFLICT (id_parlamentar_voz, cargo, legislatura)
DO
  UPDATE
  SET
    casa = EXCLUDED.casa,    
    data_inicio = EXCLUDED.data_inicio,
    data_fim = EXCLUDED.data_fim;

DELETE FROM cargos_mesa
WHERE (id_parlamentar_voz, cargo, legislatura) NOT IN
  (SELECT id_parlamentar_voz, cargo, legislatura
   FROM temp_cargos_mesa
  );

DROP TABLE temp_cargos_mesa;
COMMIT;
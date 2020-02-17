-- CARGOS EM MESA DIRETORA
BEGIN;
CREATE TEMP TABLE temp_cargos_mesa AS SELECT * FROM cargos_mesa LIMIT 0;

\copy temp_cargos_mesa FROM './data/cargos_mesa.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO cargos_mesa (id_parlamentar_voz, casa, cargo)
SELECT id_parlamentar_voz, casa, cargo
FROM temp_cargos_mesa
ON CONFLICT (id_parlamentar_voz)
DO
  UPDATE
  SET
    casa = EXCLUDED.casa,    
    cargo = EXCLUDED.cargo;

DELETE FROM cargos_mesa
WHERE (id_parlamentar_voz) NOT IN
  (SELECT id_parlamentar_voz
   FROM temp_cargos_mesa
  );

DROP TABLE temp_cargos_mesa;
COMMIT;
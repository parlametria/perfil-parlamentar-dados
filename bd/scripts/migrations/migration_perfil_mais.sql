-- PERFIL MAIS
BEGIN;
CREATE TEMP TABLE temp_perfil_mais AS SELECT * FROM perfil_mais LIMIT 0;

\copy temp_perfil_mais FROM './data/perfil_mais.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO perfil_mais (id_parlamentar_voz, indice_vinculo_economico_agro, indice_ativismo_ambiental, peso_politico)
SELECT id_parlamentar_voz, indice_vinculo_economico_agro, indice_ativismo_ambiental, peso_politico
FROM temp_perfil_mais
ON CONFLICT (id_parlamentar_voz) 
DO
  UPDATE
    SET 
      indice_vinculo_economico_agro = EXCLUDED.indice_vinculo_economico_agro,
      indice_ativismo_ambiental = EXCLUDED.indice_ativismo_ambiental,      
      peso_politico = EXCLUDED.peso_politico;
      
DELETE FROM perfil_mais
WHERE (id_parlamentar_voz) NOT IN
  (SELECT id_parlamentar_voz
   FROM temp_perfil_mais);

DROP TABLE temp_perfil_mais;
COMMIT;

-- CREATE TEMP TABLES

 -- CANDIDATOS
CREATE TEMP TABLE temp_candidatos AS SELECT * FROM candidatos LIMIT 0;

 \copy temp_candidatos FROM './data/candidatos.csv' DELIMITER ',' CSV HEADER;


-- UPDATE COLUMN id_parlamentar ON CANDIDATOS
UPDATE candidatos 
SET id_parlamentar = (SELECT t.id_parlamentar
                      FROM temp_candidatos t
                      WHERE t.cpf = candidatos.cpf);
-- CREATE COLUMN id_parlamentar
ALTER TABLE candidatos
ADD COLUMN IF NOT EXISTS id_parlamentar varchar(40) DEFAULT NULL;


-- CREATE COLUMN status_proposicao
-- ALTER TABLE proposicoes
-- ADD COLUMN IF NOT EXISTS status_proposicao varchar(40) DEFAULT 'Inativa';

-- ALTER TABLE proposicoes
-- ADD COLUMN IF NOT EXISTS id_proposicao varchar(40) DEFAULT NULL;

-- -- ALTER PRIMARY KEY VOTACOES
-- ALTER TABLE votacoes DROP CONSTRAINT votacoes_pkey;
-- ALTER TABLE votacoes ADD PRIMARY KEY (cpf, proposicao_id);

-- -- CREATE COLUMN id_parlamentar
-- ALTER TABLE candidatos
-- ADD COLUMN IF NOT EXISTS id_parlamentar varchar(40) DEFAULT NULL;

-- -- CREATE COLUMN slug
-- ALTER TABLE temas
-- ADD COLUMN IF NOT EXISTS slug varchar(255) DEFAULT 'sem-nome';

-- CREATE COLUMN id_perfil_politico em PARLAMENTARES
ALTER TABLE parlamentares
ADD COLUMN IF NOT EXISTS id_perfil_politico VARCHAR(40) DEFAULT NULL;

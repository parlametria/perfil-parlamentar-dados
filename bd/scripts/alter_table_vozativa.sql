-- CREATE COLUMN status_proposicao
ALTER TABLE proposicoes
ADD COLUMN IF NOT EXISTS status_proposicao varchar(40) DEFAULT 'Inativa';

-- ALTER PRIMARY KEY VOTACOES
ALTER TABLE votacoes DROP CONSTRAINT votacoes_pkey;
ALTER TABLE votacoes ADD PRIMARY KEY (cpf, proposicao_id);

-- CREATE COLUMN id_parlamentar
ALTER TABLE candidatos
ADD COLUMN IF NOT EXISTS id_parlamentar varchar(40) DEFAULT NULL;


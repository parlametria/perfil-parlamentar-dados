-- DROP CPF'S CONSTRAINTS
ALTER TABLE votacoes DROP CONSTRAINT votacoes_cpf_fkey;
ALTER TABLE composicao_comissoes DROP CONSTRAINT composicao_comissoes_parlamentar_cpf_fkey;
ALTER TABLE respostas DROP CONSTRAINT respostas_cpf_fkey;

-- DROP TABLE candidatos
DROP TABLE IF EXISTS "candidatos";

-- CREATE TABLE parlamentares
CREATE TABLE IF NOT EXISTS "parlamentares" (
    "id_parlamentar_voz" VARCHAR(40),
    "id_parlamentar" VARCHAR(40) DEFAULT NULL,    
    "casa" VARCHAR(255),
    "cpf" VARCHAR(255),
    "nome_civil" VARCHAR(255),
    "nome_eleitoral" VARCHAR(255),
    "genero" VARCHAR(255),
    "uf" VARCHAR(255),
    "partido" VARCHAR(255),
    "situacao" VARCHAR(255),
    "condicao_eleitoral" VARCHAR(255),
    "ultima_legislatura" VARCHAR(255),
    "em_exercicio" BOOLEAN,
    PRIMARY KEY("id_parlamentar_voz"));

\copy parlamentares FROM './data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
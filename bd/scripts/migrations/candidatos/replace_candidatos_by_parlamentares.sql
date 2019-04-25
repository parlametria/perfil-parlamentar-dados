-- DROP CPF'S CONSTRAINTS
ALTER TABLE votacoes DROP CONSTRAINT cpf;
ALTER TABLE composicao_comissoes DROP CONSTRAINT cpf;
ALTER TABLE respostas DROP CONSTRAINT cpf;

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
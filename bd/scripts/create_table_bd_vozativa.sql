CREATE TABLE IF NOT EXISTS "temas" (
    "id" INTEGER, 
    "tema" VARCHAR(255),
    "slug" VARCHAR(255),
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "usuarios" (
    "first_name" VARCHAR(255), 
    "full_name" VARCHAR(255), 
    "email" VARCHAR(255), 
    "photo" VARCHAR(255), 
    "id"  SERIAL, 
    "provider" VARCHAR(255), 
    "provider_id" VARCHAR(255), 
    "token" VARCHAR(255), 
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "candidatos" (
    "estado" VARCHAR(255), 
    "uf" VARCHAR(255), 
    "idade_posse" INTEGER, 
    "nome_coligacao" VARCHAR(255), 
    "nome_candidato" VARCHAR(255), 
    "cpf" VARCHAR(255), 
    "recebeu" BOOLEAN, 
    "num_partido" VARCHAR(255), 
    "email" VARCHAR(255), 
    "nome_social" VARCHAR(255), 
    "nome_urna" VARCHAR(255), 
    "reeleicao" VARCHAR(255), 
    "ocupacao" VARCHAR(255), 
    "nome_exibicao" VARCHAR(255), 
    "raca" VARCHAR(255), 
    "tipo_agremiacao" VARCHAR(255), 
    "n_candidatura" INTEGER, 
    "composicao_coligacao" VARCHAR(255), 
    "tem_foto" INTEGER, 
    "partido" VARCHAR(255), 
    "sg_partido" VARCHAR(255), 
    "grau_instrucao" VARCHAR(255), 
    "genero" VARCHAR(255), 
    "eleito" BOOLEAN, 
    "respondeu" BOOLEAN,
    "id_parlamentar" VARCHAR(40) DEFAULT NULL,
    PRIMARY KEY ("cpf"));    

CREATE TABLE IF NOT EXISTS "perguntas" (
    "texto" VARCHAR(500), 
    "id" INTEGER, 
    "tema_id" INTEGER REFERENCES "temas" ("id") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "proposicoes" (
    "projeto_lei" VARCHAR(255),    
    "id_votacao" INTEGER, 
    "titulo" VARCHAR(255), 
    "descricao" VARCHAR(800), 
    "tema_id" INTEGER REFERENCES "temas" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    "status_proposicao" VARCHAR(40) DEFAULT 'Inativa',
    "id_proposicao" VARCHAR(40), 
    PRIMARY KEY ("id_votacao"));

CREATE TABLE IF NOT EXISTS "votacoes" (
    "id" SERIAL, 
    "resposta" INTEGER, 
    "cpf" VARCHAR(255) REFERENCES "candidatos" ("cpf") ON DELETE SET NULL ON UPDATE CASCADE, 
    "proposicao_id" INTEGER REFERENCES "proposicoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("cpf", "proposicao_id"));

CREATE TABLE IF NOT EXISTS "respostas" (
    "id" SERIAL, 
    "resposta" INTEGER, 
    "cpf" VARCHAR(255) REFERENCES "candidatos" ("cpf") ON DELETE SET NULL ON UPDATE CASCADE, 
    "pergunta_id" INTEGER REFERENCES "perguntas" ("id") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "respostasus" (
    "id" SERIAL, 
    "resposta" INTEGER, 
    "user_id" INTEGER REFERENCES "usuarios" ("id") ON DELETE SET NULL ON UPDATE CASCADE, 
    "pergunta_id" INTEGER REFERENCES "perguntas" ("id") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "votacoesus" (
    "id" SERIAL, 
    "resposta" INTEGER, "user_id" INTEGER REFERENCES "usuarios" ("id") ON DELETE SET NULL ON UPDATE CASCADE, 
    "proposicao_id" INTEGER REFERENCES "proposicoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE, PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "temasus" (
    "id" SERIAL, 
    "usuario_id" INTEGER REFERENCES "usuarios" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    "temas_preferidos" TEXT [],
    PRIMARY KEY ("usuario_id")
);

CREATE TABLE IF NOT EXISTS "comissoes" (
    "id" VARCHAR(40),
    "sigla" VARCHAR(255),
    "nome" VARCHAR(255),
    PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "composicao_comissoes" (
    "comissao_id" VARCHAR(40) REFERENCES "comissoes" ("id") ON DELETE CASCADE ON UPDATE CASCADE, 
    "parlamentar_cpf" VARCHAR(40) REFERENCES "candidatos" ("cpf") ON DELETE CASCADE ON UPDATE CASCADE,
    "cargo" VARCHAR(255),
    "situacao" VARCHAR(255),
    PRIMARY KEY("comissao_id", "parlamentar_cpf")
);

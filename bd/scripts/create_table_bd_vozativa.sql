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
    "id_votacao" INTEGER REFERENCES "proposicoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "id_parlamentar_voz")
);

CREATE TABLE IF NOT EXISTS "respostas" (
    "id" SERIAL, 
    "resposta" INTEGER, 
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE, 
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
    "id_comissao_voz" VARCHAR(40),
    "id" INTEGER,
    "casa" VARCHAR(10),
    "sigla" VARCHAR(40),
    "nome" VARCHAR(255),
    PRIMARY KEY ("id_comissao_voz")
);

CREATE TABLE IF NOT EXISTS "composicao_comissoes" (
    "id_comissao_voz" VARCHAR(40) REFERENCES "comissoes" ("id_comissao_voz") ON DELETE CASCADE ON UPDATE CASCADE, 
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "cargo" VARCHAR(40),
    "situacao" VARCHAR(40),
    PRIMARY KEY("id_comissao_voz", "id_parlamentar_voz")
);

CREATE TABLE IF NOT EXISTS "mandatos" (
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_legislatura" INTEGER,
    "data_inicio" DATE,
    "data_fim" DATE,
    "situacao" VARCHAR(255),
    "cod_causa_fim_exercicio" INTEGER,
    "desc_causa_fim_exercicio" VARCHAR(255),
    PRIMARY KEY ("id_parlamentar_voz", "id_legislatura")
);
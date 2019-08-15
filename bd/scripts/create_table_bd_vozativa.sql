CREATE TABLE IF NOT EXISTS "temas" (
    "id_tema" INTEGER, 
    "tema" VARCHAR(255),
    "slug" VARCHAR(255),
    "ativo" BOOLEAN,
    PRIMARY KEY ("id_tema"));

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

CREATE TABLE IF NOT EXISTS "partidos" (    
    "id_partido" INTEGER,
    "sigla" VARCHAR(255),
    "tipo" VARCHAR(90),
    "situacao" VARCHAR(60),
    PRIMARY KEY("id_partido")
);

CREATE TABLE IF NOT EXISTS "parlamentares" (
    "id_parlamentar_voz" VARCHAR(40),
    "id_parlamentar" VARCHAR(40) DEFAULT NULL,
    "casa" VARCHAR(255),
    "cpf" VARCHAR(255),
    "nome_civil" VARCHAR(255),
    "nome_eleitoral" VARCHAR(255),
    "genero" VARCHAR(255),
    "uf" VARCHAR(255),
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "situacao" VARCHAR(255),
    "condicao_eleitoral" VARCHAR(255),
    "ultima_legislatura" VARCHAR(255),
    "em_exercicio" BOOLEAN,
    PRIMARY KEY("id_parlamentar_voz"));  

CREATE TABLE IF NOT EXISTS "perguntas" (
    "texto" VARCHAR(500), 
    "id" INTEGER, 
    "tema_id" INTEGER REFERENCES "temas" ("id_tema") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("id"));

CREATE TABLE IF NOT EXISTS "proposicoes" (
    "id_proposicao" INTEGER,    
    "casa" VARCHAR(40),
    "projeto_lei" VARCHAR(40), 
    "titulo" VARCHAR(255), 
    "descricao" VARCHAR(800), 
    "status_proposicao" VARCHAR(40) DEFAULT 'Inativa',
    "status_importante" VARCHAR(255) DEFAULT 'Inativa',
    PRIMARY KEY ("id_proposicao"));

CREATE TABLE IF NOT EXISTS "proposicoes_temas" (
    "id_proposicao" INTEGER REFERENCES "proposicoes" ("id_proposicao") ON DELETE SET NULL ON UPDATE CASCADE,    
    "id_tema" INTEGER REFERENCES "temas" ("id_tema") ON DELETE SET NULL ON UPDATE CASCADE,
    PRIMARY KEY ("id_proposicao", "id_tema"));

CREATE TABLE IF NOT EXISTS "votacoes" (     
    "id_proposicao" INTEGER REFERENCES "proposicoes" ("id_proposicao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_votacao" INTEGER UNIQUE,
    "objeto_votacao" VARCHAR,
    "horario" TIMESTAMP,
    "codigo_sessao" INTEGER,
    PRIMARY KEY ("id_votacao")
);

CREATE TABLE IF NOT EXISTS "votos" (     
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "id_parlamentar_voz")
);

CREATE TABLE IF NOT EXISTS "orientacoes" (     
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "voto" INTEGER,    
    PRIMARY KEY ("id_votacao", "id_partido")
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
    "id_votacao" INTEGER REFERENCES "votacoes" ("id_votacao") ON DELETE SET NULL ON UPDATE CASCADE, 
    PRIMARY KEY ("id"));

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
    "id_mandato_voz" VARCHAR(40),
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_legislatura" INTEGER,
    "data_inicio" DATE,
    "data_fim" DATE,
    "situacao" VARCHAR(255),
    "cod_causa_fim_exercicio" INTEGER,
    "desc_causa_fim_exercicio" VARCHAR(255),
    PRIMARY KEY ("id_mandato_voz")
);

CREATE TABLE IF NOT EXISTS "aderencias" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_tema" INTEGER REFERENCES "temas" ("id_tema") ON DELETE SET NULL ON UPDATE CASCADE,
    "faltou" INTEGER,
    "partido_liberou" INTEGER,
    "nao_seguiu" INTEGER,
    "seguiu" INTEGER,
    "aderencia" REAL,
    PRIMARY KEY("id_parlamentar_voz", "id_partido", "id_tema")
);

CREATE TABLE IF NOT EXISTS "liderancas" (    
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "casa" VARCHAR(40),
    "cargo" VARCHAR(40),
    PRIMARY KEY("id_parlamentar_voz", "id_partido")
);

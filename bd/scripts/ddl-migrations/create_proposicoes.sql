DROP TABLE IF EXISTS "proposicoes";

CREATE TABLE IF NOT EXISTS "proposicoes" (
    "id_proposicao" INTEGER,    
    "casa" VARCHAR(40),
    "projeto_lei" VARCHAR(40), 
    "titulo" VARCHAR(255), 
    "descricao" VARCHAR(800), 
    "status_proposicao" VARCHAR(40) DEFAULT 'Inativa',
    "status_importante" VARCHAR(255) DEFAULT 'Inativa',
    PRIMARY KEY ("id_proposicao")
);
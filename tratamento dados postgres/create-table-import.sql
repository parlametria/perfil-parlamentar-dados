
CREATE TABLE temas                               
(                                                                              
 tema character(250),
 id integer NOT NULL PRIMARY KEY
);


CREATE TABLE perguntas                               
(                                                                              
 texto character(500),
 id integer NOT NULL PRIMARY KEY,
 tema_id integer
);


CREATE TABLE proposicoes                               
(                                                                              
 id integer,
 projeto_lei character(55),
 id_votacao integer NOT NULL PRIMARY KEY,
 titulo character(150),
 descricao character(500),
 tema_id integer
);


CREATE TABLE respostas                               
(                                                                              
 cpf character(15),
 resposta integer,
 pergunta_id integer 
);

CREATE TABLE votacoes                               
(                                                                              
 cpf character(15),
 resposta integer,
 proposicao_id integer 
);


CREATE TABLE candidatos                               
(                                                                              
 estado character(50),
 uf character(10),
 idade_posse integer,
 nome_coligacao character(100),
 nome_candidato character(100),
 cpf character(15) NOT NULL PRIMARY KEY,
 recebeu boolean,
 num_partido integer,
 email character(150),
 nome_social character(100),
 nome_urna character(100),
 reeleicao integer,
 ocupacao character(100),
 nome_exibicao character(100),
 raca character(30),
 tipo_agremiacao character(250),
 n_candidatura integer,
 composicao_coligacao character(250),
 tem_foto integer,
 partido character(100),
 sg_partido character(50),
 grau_instrucao character(100),
 genero character(50),
 eleito boolean,
 respondeu boolean
);


-- \copy respostas FROM '/home/luizacs/Documentos/respostas.csv' DELIMITER ',' CSV HEADER;
-- \copy candidatos FROM '/home/luizacs/Documentos/candidatos.csv' DELIMITER ',' CSV HEADER;
-- \copy votacoes FROM '/home/luizacs/Documentos/votacoes.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE perguntas 
ADD CONSTRAINT tema_pergunta FOREIGN KEY (tema_id) REFERENCES temas (id);

ALTER TABLE proposicoes 
ADD CONSTRAINT tema_proposicoes FOREIGN KEY (tema_id) REFERENCES temas (id);

ALTER TABLE votacoes   
ADD CONSTRAINT votacoes_proposicoes FOREIGN KEY (proposicao_id) REFERENCES proposicoes (id_votacao);

ALTER TABLE respostas 
ADD CONSTRAINT cpf_respostas FOREIGN KEY (cpf) REFERENCES candidatos (cpf);

ALTER TABLE respostas 
ADD CONSTRAINT perguntas_respostas FOREIGN KEY (pergunta_id) REFERENCES perguntas (id);

ALTER TABLE votacoes 
ADD CONSTRAINT cpf_votacoes FOREIGN KEY (cpf) REFERENCES candidatos (cpf);


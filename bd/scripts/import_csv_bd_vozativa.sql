\copy temas FROM '/data/temas.csv' DELIMITER ',' CSV HEADER;
\copy candidatos FROM '/data/candidatos.csv' DELIMITER ',' CSV HEADER;
\copy perguntas FROM '/data/perguntas.csv' DELIMITER ',' CSV HEADER;
\copy proposicoes FROM '/data/proposicoes.csv' DELIMITER ',' CSV HEADER;
\copy respostas FROM '/data/respostas.csv' DELIMITER ',' CSV HEADER;
\copy votacoes FROM '/data/votacoes.csv' DELIMITER ',' CSV HEADER;

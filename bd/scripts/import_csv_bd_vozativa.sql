\copy temas FROM '/data/temas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy candidatos FROM '/data/candidatos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy perguntas FROM '/data/perguntas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy proposicoes FROM '/data/proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy respostas FROM '/data/respostas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy votacoes FROM '/data/votacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

\copy temas FROM '/data/temas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy partidos FROM '/data/partidos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy parlamentares FROM '/data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy perguntas FROM '/data/perguntas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy proposicoes FROM '/data/proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy proposicoes_temas FROM '/data/proposicoes_temas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy votacoes FROM '/data/votacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy respostas FROM '/data/respostas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy votos FROM '/data/votos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy orientacoes FROM '/data/orientacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy comissoes FROM '/data/comissoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy composicao_comissoes FROM '/data/composicao_comissoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy mandatos FROM '/data/mandatos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER; 
\copy aderencias FROM '/data/aderencia.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER; 
\copy liderancas FROM '/data/liderancas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER; 
\copy investimento_partidario FROM '/data/investimento_partidario.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy ligacoes_economicas FROM '/data/ligacoes_economicas.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

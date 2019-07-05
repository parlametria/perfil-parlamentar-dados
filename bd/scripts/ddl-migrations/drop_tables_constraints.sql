DROP TABLE IF EXISTS "liderancas";
DROP TABLE IF EXISTS "mandatos";
DROP TABLE IF EXISTS "votacoes";

ALTER TABLE respostas DROP CONSTRAINT "respostas_id_parlamentar_voz_fkey";
ALTER TABLE perguntas DROP CONSTRAINT "perguntas_tema_id_fkey";
DROP TABLE IF EXISTS "aderencia";
DROP TABLE IF EXISTS "composicao_comissoes";
DROP TABLE IF EXISTS "proposicoes";
DROP TABLE IF EXISTS "parlamentares";
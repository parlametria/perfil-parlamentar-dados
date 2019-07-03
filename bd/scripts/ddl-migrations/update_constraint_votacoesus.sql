ALTER TABLE votacoesus ADD CONSTRAINT votacoesus_proposicao_id_fkey FOREIGN KEY (id_votacao) REFERENCES votacoes (id_votacao);

ALTER TABLE respostas ADD CONSTRAINT respostas_id_parlamentar_voz_fkey FOREIGN KEY (id_parlamentar_voz) REFERENCES parlamentares (id_parlamentar_voz);
ALTER TABLE perguntas ADD CONSTRAINT perguntas_tema_id_fkey FOREIGN KEY (tema_id) REFERENCES temas (id_tema);


DELETE FROM votacoesus WHERE id_votacao IS NULL;
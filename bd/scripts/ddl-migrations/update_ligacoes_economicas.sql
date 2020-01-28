ALTER TABLE "ligacoes_economicas"
DROP CONSTRAINT "ligacoes_economicas_id_atividade_economica_fkey";

ALTER TABLE "ligacoes_economicas"
DROP CONSTRAINT "ligacoes_economicas_id_parlamentar_voz_fkey";

ALTER TABLE "ligacoes_economicas"
ADD CONSTRAINT "ligacoes_economicas_id_atividade_economica_fkey"
FOREIGN KEY ("id_atividade_economica")
REFERENCES "atividades_economicas" ("id_atividade_economica") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ligacoes_economicas"
ADD CONSTRAINT "empresas_parlamentares_id_parlamentar_voz_fkey"
FOREIGN KEY ("id_parlamentar_voz")
REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE;
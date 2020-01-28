ALTER TABLE "atividades_economicas_empresas"
DROP CONSTRAINT "atividades_economicas_empresas_cnpj_fkey";

ALTER TABLE "atividades_economicas_empresas"
DROP CONSTRAINT "atividades_economicas_empresas_id_atividade_economica_fkey";

ALTER TABLE "atividades_economicas_empresas"
ADD CONSTRAINT "atividades_economicas_empresas_cnpj_fkey"
FOREIGN KEY ("cnpj")
REFERENCES "empresas" ("cnpj") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "atividades_economicas_empresas"
ADD CONSTRAINT "atividades_economicas_empresas_id_atividade_economica_fkey"
FOREIGN KEY ("id_atividade_economica")
REFERENCES "atividades_economicas" ("id_atividade_economica") ON DELETE CASCADE ON UPDATE CASCADE;

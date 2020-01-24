ALTER TABLE "empresas_parlamentares"
DROP CONSTRAINT "empresas_parlamentares_cnpj_fkey";

ALTER TABLE "empresas_parlamentares"
DROP CONSTRAINT "empresas_parlamentares_id_parlamentar_voz_fkey";

ALTER TABLE "empresas_parlamentares"
ADD CONSTRAINT "empresas_parlamentares_cnpj_fkey"
FOREIGN KEY ("cnpj")
REFERENCES "empresas" ("cnpj") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "empresas_parlamentares"
ADD CONSTRAINT "empresas_parlamentares_id_parlamentar_voz_fkey"
FOREIGN KEY ("id_parlamentar_voz")
REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE;

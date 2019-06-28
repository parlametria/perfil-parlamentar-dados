ALTER TABLE "parlamentares" 
 RENAME COLUMN "partido" TO "id_partido";

UPDATE "parlamentares" 
 SET "id_partido" = NULL;

ALTER TABLE "parlamentares" 
 ALTER COLUMN "id_partido" TYPE integer USING (id_partido::integer);

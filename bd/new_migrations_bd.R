library(tidyverse)
source(here::here("bd/send_log_to_bot.R"))
Sys.setenv(TZ='America/Recife')

host <- Sys.getenv("PGHOST")
user <- Sys.getenv("PGUSER")
database <- Sys.getenv("PGDATABASE")
## password env PGPASSWORD

execute_migration <- function(migration, log_output) {
  system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', migration,
                ' -a -b -e >> ', log_output, ' 2>&1'))
  write_log("=======================================================", log_output)
}

write_log <- function(message, log_output) {
  system(paste0('echo ', message, ' >> ', log_output))
}

log_file <- here::here(paste0("bd/scripts/logs/",  gsub(":", "", gsub(" ", "_", Sys.time())), "_log.txt"))

write_log(Sys.time(), log_file)
write_log("=======================================================", log_file)

## RECRIA TABELA DE COMPOSIÇÃO COMISSÕES
file = here::here("bd/scripts/ddl-migrations/update_composicao_comissoes.sql")
execute_migration(file, log_file)

## ATUALIZA DADOS DE COMISSÕES
file = here::here("bd/scripts/migrations/migration_comissoes.sql")
execute_migration(file, log_file)

## REALIZA MIGRATION DE COMPOSIÇÃO COMISSÕES
file = here::here("bd/scripts/migrations/migration_composicao_comissoes.sql")
execute_migration(file, log_file)

if (length(grep("ROLLBACK", readLines(log_file), value = TRUE)) > 0) {
  error <- paste0('Um erro ocorreu durante a execução das migrações. Mais informações em ', log_file)
  send_log_to_bot(error)
  print(error)
} else {
  success <- "As migrações foram realizadas com sucesso!"
  send_log_to_bot(success)
  print(success)
}
library(tidyverse)
source(here::here("bd/send_log_to_bot.R"))

log <- ""

host <- Sys.getenv("PGHOST")
user <- Sys.getenv("PGUSER")
database <- Sys.getenv("PGDATABASE")
## password env PGPASSWORD

log_file <- here::here(paste0("bd/scripts/logs/",  Sys.Date(), "_log.txt"))

## PARTIDOS
file = here::here("bd/scripts/migrations/migration_partidos.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e > ', log_file, ' 2>&1'))

## TEMAS
file = here::here("bd/scripts/migrations/migration_temas.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## PARLAMENTARES
file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## LIDERANCAS
file = here::here("bd/scripts/migrations/migration_liderancas.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## MANDATOS
file = here::here("bd/scripts/migrations/migration_mandatos.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## ADERENCIA
file = here::here("bd/scripts/migrations/migration_aderencia.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## COMISSOES
file = here::here("bd/scripts/migrations/migration_comissoes.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## COMPOSICAO COMISSOES
file = here::here("bd/scripts/migrations/migration_composicao_comissoes.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## PROPOSICOES
file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## PROPOSICOES_TEMAS
file = here::here("bd/scripts/migrations/migration_proposicoes_temas.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## VOTACOES
file = here::here("bd/scripts/migrations/migration_votacoes.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## VOTOS
file = here::here("bd/scripts/migrations/migration_votos.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

## ORIENTACOES
file = here::here("bd/scripts/migrations/migration_orientacoes.sql")
system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', file, ' -a -b -e >> ', log_file, ' 2>&1'))

if (length(grep("ROLLBACK", readLines(log_file), value = TRUE)) > 0) {
  error <- paste0('Um erro ocorreu durante a execução das migrações. Mais informações em ', log_file)
  send_log_to_bot(error)
  print(error)
} else {
  success <- "As migrações foram realizadas com sucesso!"
  send_log_to_bot(success)
  print(success)
}
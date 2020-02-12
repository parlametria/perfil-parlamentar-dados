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

## PARTIDOS
file = here::here("bd/scripts/migrations/migration_partidos.sql")
execute_migration(file, log_file)

## TEMAS
file = here::here("bd/scripts/migrations/migration_temas.sql")
execute_migration(file, log_file)

## PARLAMENTARES
file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
execute_migration(file, log_file)

## LIDERANCAS
file = here::here("bd/scripts/migrations/migration_liderancas.sql")
execute_migration(file, log_file)

## MANDATOS
file = here::here("bd/scripts/migrations/migration_mandatos.sql")
execute_migration(file, log_file)

## ADERENCIA
file = here::here("bd/scripts/migrations/migration_aderencia.sql")
execute_migration(file, log_file)

## COMISSOES
file = here::here("bd/scripts/migrations/migration_comissoes.sql")
execute_migration(file, log_file)

## COMPOSICAO COMISSOES
file = here::here("bd/scripts/migrations/migration_composicao_comissoes.sql")
execute_migration(file, log_file)

## PROPOSICOES
file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
execute_migration(file, log_file)

## PROPOSICOES_TEMAS
file = here::here("bd/scripts/migrations/migration_proposicoes_temas.sql")
execute_migration(file, log_file)

## VOTACOES
file = here::here("bd/scripts/migrations/migration_votacoes.sql")
execute_migration(file, log_file)

## VOTOS
file = here::here("bd/scripts/migrations/migration_votos.sql")
execute_migration(file, log_file)

## ORIENTACOES
file = here::here("bd/scripts/migrations/migration_orientacoes.sql")
execute_migration(file, log_file)

## INVESTIMENTO PARTIDARIO
file = here::here("bd/scripts/migrations/migration_investimento_partidario.sql")
execute_migration(file, log_file)

## INVESTIMENTO PARTIDARIO PARLAMENTAR
file = here::here("bd/scripts/migrations/migration_investimento_partidario_parlamentar.sql")
execute_migration(file, log_file)

## PERFIL MAIS
file = here::here("bd/scripts/migrations/migration_perfil_mais.sql")
execute_migration(file, log_file)

## ATIVIDADES ECONOMICAS
file = here::here("bd/scripts/migrations/migration_atividades_economicas.sql")
execute_migration(file, log_file)

## LIGACOES ECONOMICAS
file = here::here("bd/scripts/migrations/migration_ligacoes_economicas.sql")
execute_migration(file, log_file)

## EMPRESAS
file = here::here("bd/scripts/migrations/migration_empresas.sql")
execute_migration(file, log_file)

## ATIVIDADES ECONOMICAS EMPRESAS
file = here::here("bd/scripts/migrations/migration_atividades_economicas_empresas.sql")
execute_migration(file, log_file)

## EMPRESAS DOS PARLAMENTARES
file = here::here("bd/scripts/migrations/migration_empresas_parlamentares.sql")
execute_migration(file, log_file)

## CARGOS DE MESA DIRETORA DOS PARLAMENTARES
file = here::here("bd/scripts/migrations/migration_empresas_parlamentares.sql")
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
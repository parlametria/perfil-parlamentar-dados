library(tidyverse)
source(here::here("bd/send_log_to_bot.R"))

log <- ""

host <- Sys.getenv("PGHOST")
user <- Sys.getenv("PGUSER")
database <- Sys.getenv("PGDATABASE")
## password env PGPASSWORD

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para parlamentares...\n")
    file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Parlamentares")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para proposicoes...\n")
    file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Proposições")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Votações...\n")
    file = here::here("bd/scripts/migrations/migration_votacoes.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Votações")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Comissões...\n")
    file = here::here("bd/scripts/migrations/migration_comissoes.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Comissões")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Composição de Comissões...\n")
    file = here::here("bd/scripts/migrations/migration_composicao_comissoes.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Composição de Comissões")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Lideranças...\n")
    file = here::here("bd/scripts/migrations/migration_liderancas.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Composição de lideranças")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Mandatos...\n")
    file = here::here("bd/scripts/migrations/migration_mandatos.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Mandatos")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Realizando migrações para Aderência...\n")
    file = here::here("bd/scripts/migrations/migration_aderencia.sql")
    system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' < ', file))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução da migração de Composição de Aderência")
    log <- paste0(log, date(), log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

send_log_to_bot(log)
success <- "As migrações foram realizadas com sucesso!"
send_log_to_bot(success)
print(success)
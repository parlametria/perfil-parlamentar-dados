library(tidyverse)
source(here::here("bd/send_log_to_bot.R"))

log <- ""

tryCatch(
  {
    send_log_to_bot("Realizando migrações para parlamentares...")
    file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
    system(paste0('psql -h localhost -U postgres -d vozativa < ', file))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução da migração de Parlamentares")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Realizando migrações para proposicoes...")
    file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
    system(paste0('psql -h localhost -U postgres -d vozativa < ', file))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução da migração de Proposições")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Realizando migrações para Votações...")
    file = here::here("bd/scripts/migrations/migration_votacoes.sql")
    system(paste0('psql -h localhost -U postgres -d vozativa < ', file))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução da migração de Votações")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Realizando migrações para Comissões...")
    file = here::here("bd/scripts/migrations/migration_comissoes.sql")
    system(paste0('psql -h localhost -U postgres -d vozativa < ', file))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução da migração de Comissões")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Realizando migrações para Composição de Comissões...")
    file = here::here("bd/scripts/migrations/migration_composicao_comissoes.sql")
    system(paste0('psql -h localhost -U postgres -d vozativa < ', file))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução da migração de Composição de Comissões")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

success <- "As migrações foram realizadas com sucesso!"
send_log_to_bot(success)
print(success)
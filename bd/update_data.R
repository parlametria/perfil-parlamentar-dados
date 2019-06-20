library(tidyverse)
library(here)

source(here::here("bd/send_log_to_bot.R"))

log <- ""
send_log_to_bot(paste0(date(), " - Atualização dos dados iniciada"))

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Parlamentares...\n")
    source(here::here("crawler/parlamentares/export_parlamentares.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Parlamentares")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Comissões...\n")
    source(here::here("crawler/parlamentares/comissoes/export_comissoes.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Comissões")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Lideranças...\n")
    source(here::here("crawler/parlamentares/liderancas/export_liderancas.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Lideranças")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Mandatos...\n")
    source(here::here("crawler/parlamentares/mandatos/export_mandatos.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Mandatos")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Votações...\n")
    source(here::here("crawler/votacoes/fetcher_votos.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Votações")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Votos e Orientação...\n")
    source(here::here("crawler/votacoes/votos_orientacao/export_votos_orientacao.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Votos e Orientação")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando processamento dos dados para o formato do BD...\n")
    source(here::here("bd/export_dados_tratados_bd.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante o processamento dos dados para o formato do BD")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

send_log_to_bot(log)
success <- "A Atualização dos dados foi realizada com sucesso!"
send_log_to_bot(success)
print(success)

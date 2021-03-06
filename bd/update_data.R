library(tidyverse)
library(here)
Sys.setenv(TZ='America/Recife')

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
    log <- paste0(log, date(), " - Executando crawler de Votos (posições)...\n")
    source(here::here("crawler/votacoes/votos/export_votos_posicoes.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Votos (posições)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Votos (aderência)...\n")
    source(here::here("crawler/votacoes/votos/export_votos.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Votos (aderência)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Orientações...\n")
    source(here::here("crawler/votacoes/orientacoes/export_orientacoes.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Orientações")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Votações (informações detalhadas)...\n")
    source(here::here("crawler/votacoes/votacoes_nominais/export_votacoes_info.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Votações (informações detalhadas)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Investimento Partidário...\n")
    source(here::here("parlametria/crawler/resumo/investimento_partidario/export_investimento_partidario.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Investimento Partidário")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Cargos Políticos...\n")
    source(here::here("parlametria/crawler/cargos_politicos/export_cargos_politicos.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Cargos Políticos")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Resumo em Cargos (comissões e lideranças)...\n")
    source(here::here("parlametria/crawler/resumo/cargos_resumo/export_cargos_resumo.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Resumo em Cargos (comissões e lideranças)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando processador dos dados para o perfil mais...\n")
    source(here::here("parlametria/processor/export_dados_perfil_mais.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução processador dos dados para o perfil mais")
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

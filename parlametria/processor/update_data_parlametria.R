library(tidyverse)
library(here)
Sys.setenv(TZ='America/Recife')

source(here::here("bd/send_log_to_bot.R"))

log <- ""
send_log_to_bot(paste0(date(), " - Atualização dos dados do módulo parlametria iniciada"))

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Coautorias...\n")
    source(here::here("parlametria/crawler/articulacoes/export_articulacoes_ambientalistas.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Coautorias")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Tereza Cristina...\n")
    source(here::here("parlametria/crawler/articulacoes/export_articulacoes_tereza_cristina.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Coautorias de Tereza Cristina")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de cargos políticos...\n")
    source(here::here("parlametria/crawler/cargos_politicos/export_cargos_politicos.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Coautorias de cargos políticos")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de discursos da RAC...\n")
    source(here::here("parlametria/crawler/discursos_rac/export_discursos_rac.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Coautorias de discursos da RAC")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de parlamentares sócios de empresas agrícolas...\n")
    source(here::here("parlametria/crawler/empresas/socios_empresas/parlamentares/export_socios_empresas_agricolas_parlamentares.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de parlamentares sócios de empresas agrícolas")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de doadores sócios de empresas agrícolas...\n")
    source(here::here("parlametria/crawler/empresas/socios_empresas/doadoes_campanha/export_socios_empresas_agricolas_doadores_campanha.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de doadores sócios de empresas agrícolas")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de doadores para parlamentares...\n")
    source(here::here("parlametria/crawler/empresas/socios_empresas/doadoes_campanha/export_socios_empresas_doadores_campanha.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de doadores para parlamentares")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de propriedades rurais dos parlamentares...\n")
    source(here::here("parlametria/crawler/patrimonio/propriedades-rurais/export_propriedades_rurais.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de propriedades rurais dos parlamentares")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Receitas (doações partidárias)...\n")
    source(here::here("parlametria/crawler/receitas/export_receitas_tse.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Receitas (doações partidárias)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Receitas dos parlamentares nas eleições de 2018...\n")
    source(here::here("parlametria/crawler/receitas/export_receitas_tse.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Receitas dos parlamentares nas eleições de 2018")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de requerimentos de informação...\n")
    source(here::here("parlametria/crawler/req_informacao_por_assunto/export_req_informacao_por_assunto.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de requerimentos de informação")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Resumo do parlamentar (aderência)...\n")
    source(here::here("parlametria/crawler/resumo/aderencia/export_aderencia.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Resumo do parlamentar (aderência)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Resumo do parlamentar (cargos em comissões e partidos)...\n")
    source(here::here("parlametria/crawler/resumo/cargos_resumo/export_cargos_resumo.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Resumo do parlamentar (cargos em comissões e partidos)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de Resumo do parlamentar (investimento partidário)...\n")
    source(here::here("parlametria/crawler/resumo/investimento_partidario/export_investimento_partidario.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de Resumo do parlamentar (investimento partidário)")
    message(log_error)
    log <- paste0(log, date(), " ", log_error)
    send_log_to_bot(log)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    log <- paste0(log, date(), " - Executando crawler de score ruralista...\n")
    source(here::here("parlametria/crawler/score_ruralistas/export_score_ambientalista.R"))
  },
  error=function(cond) {
    log_error <- get_log_error(cond, "Um erro ocorreu durante a execução do crawler de score ruralista")
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
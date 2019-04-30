library(tidyverse)
library(here)

source(here::here("bd/send_log_to_bot.R"))

tryCatch(
  {
    send_log_to_bot("Executando crawler de Parlamentares...")
    source(here::here("crawler/parlamentares/export_parlamentares.R"))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução do crawler de Parlamentares")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Executando crawler de Comissões...")
    source(here::here("crawler/parlamentares/comissoes/export_comissoes.R"))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução do crawler de Comissões")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Executando crawler de Votações...")
    source(here::here("crawler/votacoes/fetcher_votos.R"))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante a execução do crawler de Votações")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    send_log_to_bot("Executando processamento dos dados para o formato do BD...")
    source(here::here("bd/export_dados_tratados_bd.R"))
  },
  error=function(cond) {
    send_error_log_to_bot(cond, "Um erro ocorreu durante o processamento dos dados para o formato do BD")
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

success <- "A Atualização dos dados foi realizada com sucesso!"
send_log_to_bot(success)
print(success)

#' @title Processa todos os cargos de eleição desde 1998
#' @description Processa os cargos políticos e seus ocupantes desde 1998.
#' @return Dataframe contendo os cargos políticos de 1998 a 2018.
#' @example analyzer_cargos_politicos()
analyzer_cargos_politicos <- function() {
  library(tidyverse)
  source(here::here("crawler/parlamentares/cargos_politicos/fetch_cargos_politicos.R"))
  
  cargos_parlamentares <- fetch_all_cargos_politicos()
    
  cargos_parlamentares <- cargos_parlamentares %>% 
    select(id_deputado = id, 
           cpf, 
           nome_eleitoral, 
           partido = sg_partido, 
           uf, 
           ano_eleicao = ANO_ELEICAO,
           num_turno = NUM_TURNO,
           cargo = DESCRICAO_CARGO, 
           uf_eleitoral = SIGLA_UE,
           situacao_candidatura = DES_SITUACAO_CANDIDATURA,
           situacao_totalizacao_turno = DESC_SIT_TOT_TURNO,
           numero_urna = NUMERO_CANDIDATO,
           sigla_partido_eleicao = SIGLA_PARTIDO,
           composicao_coligacao = COMPOSICAO_COLIGACAO,
           votos = QTDE_VOTOS
    ) %>% 
    mutate(composicao_coligacao = if_else(str_detect(composicao_coligacao, '#NE#|#NULO#'),
                                          as.character(NA),
                                          composicao_coligacao))
  return(cargos_parlamentares)
}
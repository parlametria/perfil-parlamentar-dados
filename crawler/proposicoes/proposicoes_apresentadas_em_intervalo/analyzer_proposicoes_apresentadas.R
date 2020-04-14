#' @title Processa metadados para proposições apresentadas na Câmara em um intervalo de tempo
#' @description Usando a API da Câmara dos deputados recupera quais as proposições apresentadas em um intervalo
#' de tempo e quais os metadados dessas proposições
#' @param data_inicial Data de Início do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @param data_final Data Final do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @return Dataframe contendo informações das proposições
#' @examples
#' proposicao <- process_props_apresentadas_intervalo("", "")
process_props_apresentadas_intervalo <- function(data_inicial, data_final) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/proposicoes/proposicoes_apresentadas_em_intervalo/fetcher_proposicoes_apresentadas.R"))
  source(here::here("crawler/votacoes/votacoes_nominais/votacoes_com_inteiro_teor/analyzer_votacoes_com_inteiro_teor.R"))
  
  proposicoes <- fetch_proposicoes_votadas_intervalo(data_inicial, data_final)
  
  proposicoes_metadados <-
    purrr::map_df(proposicoes %>% 
                    distinct(id) %>% 
                    pull(id),
                  ~ fetch_info_proposicao(.x))
  
  proposicoes_alt <- proposicoes_metadados %>% 
    select(id,
           nome,
           data_apresentacao,
           ementa,
           autor,
           indexacao,
           tema,
           uri_tramitacao)
  
  return(proposicoes_alt)
}

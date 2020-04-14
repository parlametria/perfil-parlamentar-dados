#' @title Processa metadados para proposições apresentadas na Câmara em um intervalo de tempo
#' @description Usando a API da Câmara dos deputados recupera quais as proposições apresentadas em um intervalo
#' de tempo e quais os metadados dessas proposições
#' @param data_inicial Data de Início do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @param data_final Data Final do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @return Dataframe contendo informações das proposições
#' @examples
#' proposicoes <- process_props_apresentadas_intervalo_camara("2020-03-11", "2020-04-14")
process_props_apresentadas_intervalo_camara <- function(data_inicial, data_final) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/proposicoes/proposicoes_apresentadas_em_intervalo/fetcher_proposicoes_apresentadas_em_intervalo_camara.R"))
  source(here::here("crawler/votacoes/votacoes_nominais/votacoes_com_inteiro_teor/analyzer_votacoes_com_inteiro_teor.R"))
  
  proposicoes <- fetcher_proposicoes_em_intervalo_camara(data_inicial, data_final)
  
  proposicoes_metadados <- tryCatch({
    data <- purrr::map_df(proposicoes %>%
                            distinct(id) %>%
                            pull(id),
                          ~ fetch_info_proposicao(.x))
  }, error = function(e) {
    return(tribble(~id,
                   ~nome,
                   ~data_apresentacao,
                   ~ementa,
                   ~autor,
                   ~indexacao,
                   ~tema,
                   ~uri_tramitacao))
  })
  
  proposicoes_alt <- proposicoes_metadados %>% 
    mutate(casa = "camara") %>% 
    select(id,
           casa,
           nome,
           data_apresentacao,
           ementa,
           autor,
           indexacao,
           tema,
           uri_tramitacao)
  
  return(proposicoes_alt)
}

#' @title Processa metadados para proposições apresentadas no Senado em um intervalo de tempo
#' @description Usando a API do Senado Federal, recupera quais as proposições apresentadas em um intervalo
#' de tempo e quais os metadados dessas proposições
#' @param data_inicial Data de Início do intervalo para a apresentação das proposições. Formato YYYYMMDD.
#' @param data_final Data Final do intervalo para a apresentação das proposições. Formato YYYYMMDD.
#' @return Dataframe contendo informações das proposições
#' @examples
#' proposicao <- process_props_apresentadas_intervalo_senado(20200311, gsub("-", "", Sys.Date()))
process_props_apresentadas_intervalo_senado <-
  function(data_inicial, data_final) {
    library(tidyverse)
    source(here::here("crawler/proposicoes/proposicoes_apresentadas_em_intervalo/fetcher_proposicoes_apresentadas_em_intervalo_senado.R"))
    source(here::here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
    
    proposicoes <-
      fetcher_proposicoes_em_intervalo_senado(data_inicial, data_final)
    
    proposicoes_metadados <-
      purrr::map_df(proposicoes %>%
                      distinct(id) %>%
                      pull(id),
                    ~ fetch_proposicoes_senado(.x))
    
    proposicoes_alt <- proposicoes_metadados %>%
      mutate(indexacao = "",
             casa = "senado") %>%
      select(id,
             casa,
             nome,
             data_apresentacao,
             ementa,
             autor,
             indexacao,
             tema,
             uri_tramitacao)
    
    return(proposicoes_alt)
  }

#' @title Processa metadados para proposições apresentadas no Congresso(Câmara e Senado) em um intervalo de tempo
#' @description Usando as APIs do Congresso(Câmara dos deputados e Senado) recupera quais as proposições apresentadas em um intervalo
#' de tempo e quais os metadados dessas proposições
#' @param data_inicial Data de Início do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @param data_final Data Final do intervalo para a apresentação das proposições. FOrmato YYYY-MM-DD.
#' @return Dataframe contendo informações das proposições
#' @examples
#' proposicoes <- process_props_apresentadas_intervalo("2020-03-11", "2020-04-14")
process_props_apresentadas_intervalo <- function(data_inicial, data_final) {
  library(tidyverse)
  
  proposicoes_camara <- process_props_apresentadas_intervalo_camara(data_inicial, data_final)
  proposicoes_senado <- process_props_apresentadas_intervalo_senado(gsub("-", "", data_inicial), gsub("-", "", data_final))
  
  proposicoes_apresentadas <- proposicoes_camara #%>% 
    dplyr::bind_rows(proposicoes_senado)
  
  return(proposicoes_apresentadas)
}
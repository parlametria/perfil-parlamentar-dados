#' @title Processa dados de deputados
#' @description Processa informações sobre os deputados das legislaturas 55 e 56
#' @return Dataframe contendo informações sobre os deputados
#' @examples
#' #' processa_dados_deputados()
processa_dados_deputados <- function() {
  library(tidyverse)
  library(here)
  
  # Lista das legislaturas de interesse
  legislaturas_list <- c(55, 56)
  
  source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  deputados <- purrr::map_df(legislaturas_list, ~ fetch_deputados(.x))
  
  deputados <- deputados %>% 
    dplyr::group_by(id) %>% 
    dplyr::rename("ultima_legislatura" = "legislatura") %>% 
    dplyr::mutate(ultima_legislatura = max(ultima_legislatura)) %>% 
    dplyr::mutate(sg_partido = padroniza_sigla(sg_partido)) %>% 
    unique()
  
  return(deputados)
}


#' @title Processa dados de parlamentares
#' @description Processa informações sobre os parlamentares da legislatura atual
#' @return Dataframe contendo informações sobre os parlamentares (deputados e senadores)
#' @examples
#' processa_dados_parlamentares()
processa_dados_parlamentares <- function() {
  deputados <- processa_dados_deputados()
  return(deputados)
}


#' @title Recupera e processa os dados sobre cargos da Mesa Diretora
#' @description Recupera e processa os dados de cargos na Mesa Diretora para a Câmara dos Deputados e Senado Federal.
#' @return Dataframe contendo parlamentares com cargos na Mesa da Câmara.
#' @examples
#' parlamentares_cargos <- processa_cargos_mesa()
processa_cargos_mesa <- function() {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/cargos_mesa/fetcher_cargos_mesa.R"))
  
  cargos_mesa <-fetch_cargos_mesa_camara() %>% 
    rbind(fetch_cargos_mesa_senado()) %>% 
    select(id_parlamentar = id, casa, cargo, data_inicio, data_fim, legislatura)
  
  return(cargos_mesa)
  
}
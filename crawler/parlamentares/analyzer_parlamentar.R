#' @title Processa dados de deputados
#' @description Processa informações sobre os deputados da legislatura atual
#' @return Dataframe contendo o id do parlamentar, casa atual, nome e cpf
#' @examples
#' #' processa_dados_deputados()
processa_dados_deputados <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))
  
  deputados <- fetch_deputados(legislatura = 56)
  
  deputados_alt <- deputados %>% 
    mutate(casa = "câmara") %>% 
    select(id, casa, nome_civil, cpf)
  
  return(deputados_alt)
}


#' @title Processa dados de parlamentares
#' @description Processa informações sobre os parlamentares da legislatura atual
#' @return Dataframe contendo o id do parlamentar, casa atual, nome e cpf
#' @examples
#' #' processa_dados_parlamentares()
processa_dados_parlamentares <- function() {
  library(tidyverse)
  library(here)
  
  deputados <- processa_dados_deputados()
  
  return(deputados)
}


#' @title Processa dados de deputados
#' @description Processa informações sobre os deputados da legislatura atual
#' @return Dataframe contendo informações sobre os deputados
#' @examples
#' #' processa_dados_deputados()
processa_dados_deputados <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))
  
  deputados <- fetch_deputados(legislatura = 56)
  
  return(deputados)
}


#' @title Processa dados de parlamentares
#' @description Processa informações sobre os parlamentares da legislatura atual
#' @return Dataframe contendo informações sobre os parlamentares (deputados e senadores)
#' @examples
#' #' processa_dados_parlamentares()
processa_dados_parlamentares <- function() {
  deputados <- processa_dados_deputados()
  return(deputados)
}


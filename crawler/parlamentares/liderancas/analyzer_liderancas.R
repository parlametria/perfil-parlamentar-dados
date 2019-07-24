#' @title Processa dados de lideranças da Câmara e do Senado
#' @description Executa funções que recuperam dados de liderança na Câmara e no Senado.
#' @return Dataframe contendo informações das lideranças
#' @examples
#' liderancas <- processa_liderancas(56)
processa_liderancas <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/parlamentares/liderancas/fetcher_liderancas_camara.R"))
  source(here("crawler/parlamentares/liderancas/fetcher_liderancas_senado.R"))
  
  liderancas_camara <- fetch_liderancas_camara()
  
  # liderancas_senado <- fetch_liderancas_senado()
  # 
  # liderancas <- liderancas_camara %>% 
  #   rbind(liderancas_senado)
  
  return(liderancas_camara)
}
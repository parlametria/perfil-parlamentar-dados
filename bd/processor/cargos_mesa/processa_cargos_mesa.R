#' @title Processa dados de cargos de mesa
#' @description Processa os dados de cargos de mesa e retorna no formato  a ser utilizado pelo banco de dados
#' @param liderancas_path Caminho para o arquivo de dados de cargos de mesa sem tratamento
#' @return Dataframe com informações dos cargos de mesa
processa_cargos_mesa <- function(cargos_mesa_path = here::here("crawler/raw_data/cargos_mesa.csv")) {
  library(tidyverse)
  
  cargos_mesa <- read_csv(cargos_mesa_path) %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id_parlamentar))
    ) %>% 
    select(id_parlamentar_voz, casa, cargo, data_inicio, data_fim, legislatura)
  
  return(cargos_mesa)
}
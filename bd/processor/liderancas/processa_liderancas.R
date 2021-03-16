#' @title Processa dados de lideranças
#' @description Processa os dados de lideranças e retorna no formato  a ser utilizado pelo banco de dados
#' @param liderancas_path Caminho para o arquivo de dados de lideranças sem tratamento
#' @return Dataframe com informações dos lideranças
processa_liderancas <- function(liderancas_path = here::here("crawler/raw_data/liderancas.csv")) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  liderancas <- read_csv(liderancas_path) %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id))
    )
  
  liderancas_partidos <- liderancas %>% 
    mutate(bloco_partido = if_else(bloco_partido == "PODE", "PODEMOS", bloco_partido)) %>% 
    group_by(bloco_partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    dplyr::mutate(id_partido = map_sigla_id(bloco_partido)) %>% 
    ungroup()
  
  liderancas_alt <- liderancas %>%
    left_join(liderancas_partidos %>% select(bloco_partido, id_partido),
              by = c("bloco_partido")) %>% 
    select(id_parlamentar_voz, id_partido, casa, cargo)
  
  return(liderancas_alt)
}
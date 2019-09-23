#' @title Processa dados de comissões
#' @description Processa os dados de comissões e retorna no formato  a ser utilizado pelo banco de dados
#' @param comissoes_data_path Caminho para o arquivo de dados de comissões sem tratamento
#' @return Dataframe com informações das comissões
processa_comissoes <- function(comissoes_data_path = here::here("crawler/raw_data/comissoes.csv")) {
  library(tidyverse)
  library(here)
  
  comissoes <- readr::read_csv(comissoes_data_path, col_types = cols(id = "i")) %>% 
    dplyr::mutate(id_comissao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                           id)) %>%
    dplyr::select(id_comissao_voz, id, casa, sigla, nome)
  
  return(comissoes)
}
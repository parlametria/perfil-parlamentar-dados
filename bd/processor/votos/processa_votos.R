#' @title Processa dados de votos
#' @description Processa os dados de votos e retorna no formato  a ser utilizado pelo banco de dados
#' @param votos_posicoes_data_path Caminho para o arquivo de dados de votos das posições do questionário VA
#' @param votos_va_data_path Caminho para o arquivo de dados de votos das proposições selecionadas na legislatura Atual
#' @param parlamentares_path Caminho para o arquivo de dados de parlamentares
#' @return Dataframe com informações das votos
processa_votos <- function(votos_posicoes_data_path = here::here("crawler/raw_data/votos_posicoes.csv"),
                           votos_va_data_path = here::here("crawler/raw_data/votos.csv"),
                           parlamentares_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  votos_posicoes <- read_csv(votos_posicoes_data_path, col_types = cols(id_parlamentar = "i", id_votacao = "i", voto = "i")) %>% 
    select(id_votacao, id_parlamentar, casa, voto)
  
  votos_va <- read_csv(votos_va_data_path, col_types = cols(id_parlamentar = "i", id_votacao = "i", voto = "i")) %>% 
    select(id_votacao, id_parlamentar, casa, voto)
  
  votacoes <- votos_posicoes %>% 
    rbind(votos_va) %>% 
    distinct(id_votacao, id_parlamentar, .keep_all = TRUE)
  
  parlamentares <- read_csv(parlamentares_path, col_types = cols(id = "c"))
    
  votacoes_select <- votacoes %>%
    filter(id_parlamentar %in% (parlamentares %>% pull(id))) %>% ## garante que apenas deputados com info tenham seus votos salvos
    dplyr::mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                         id_parlamentar)) %>% 
    dplyr::mutate(id_votacao = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                      id_votacao)) %>% 
    dplyr::select(id_votacao, id_parlamentar_voz, voto)
  
  return(votacoes_select)
}

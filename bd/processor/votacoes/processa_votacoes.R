#' @title Cria tabela de votações que conecta id das votações aos ids das proposições
#' @description Cria tabela de votações que conecta id das votações aos ids das proposições
#' @param votos_posicoes_data_path Caminho para o arquivo de dados de votos das posições do questionário VA
#' @param votos_va_data_path Caminho para o arquivo de dados de votos das proposições selecionadas na legislatura Atual
#' @return Dataframe com informações dos links id_votacao e id_proposicao
processa_votacoes <- function(votos_posicoes_data_path = here::here("crawler/raw_data/votos_posicoes.csv"),
                              votos_va_data_path = here::here("crawler/raw_data/votos.csv"),
                              votacoes_info_data_path = here::here("crawler/raw_data/votacoes_info.csv")) {
  library(tidyverse)
  library(here)
  
  votos_posicoes <- read_csv(votos_posicoes_data_path, col_types = cols(id_proposicao = "c", 
                                                                        id_parlamentar = "i", 
                                                                        id_votacao = "i", 
                                                                        voto = "i")) %>% 
    distinct(id_proposicao, id_votacao) %>% 
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>%
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    mutate(casa = "camara") %>% 
    select(id_proposicao, id_votacao, casa)
  
  votos_va <- read_csv(votos_va_data_path, col_types = cols(id_proposicao = "c", 
                                                            id_parlamentar = "i", 
                                                            id_votacao = "i", 
                                                            voto = "i")) %>% 
    select(id_proposicao, id_votacao, casa)
  
  votacoes_info <- read_csv(votacoes_info_data_path, col_types = cols(id_proposicao = "c", 
                                                                      id_votacao = "i"))
  
  votacoes <- votos_posicoes %>% 
    rbind(votos_va) %>% 
    rbind(tibble(id_proposicao = "46249", id_votacao = 99999, casa = "camara")) %>% ## ID especial para a PL 6299/2002
    distinct(id_proposicao, id_votacao, casa) %>%
    left_join(votacoes_info, by = c("id_proposicao", "id_votacao")) %>%
    dplyr::mutate(id_proposicao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2),
                                             id_proposicao)) %>%
    dplyr::mutate(id_votacao = paste0(dplyr::if_else(casa == "camara", 1, 2),
                                      id_votacao)) %>%
    select(id_proposicao_voz, id_votacao, objeto_votacao, datetime, codigo_sessao)
  
  return(votacoes)
}
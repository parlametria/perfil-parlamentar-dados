#' @title Cria tabela de orientações
#' @description Cria tabela com as orientações dos partidos para votações realizadas em 2019
#' @param orientacoes_data_path Caminho para o arquivo de dados de orientações
#' @return Dataframe com informações das orientações
processa_orientacoes <- function(votos_path = here::here("crawler/raw_data/votos.csv"),
                                 orientacoes_data_path = here::here("crawler/raw_data/orientacoes.csv")) {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  source(here::here("crawler/votacoes/aderencia/processa_dados_aderencia.R"))
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  votos <- read_csv(votos_path, col_types = cols(.default = "c", id_votacao = "i", voto = "i")) %>% 
    mutate(partido = padroniza_sigla(partido))
  
  orientacoes <- read_csv(orientacoes_data_path, col_types = cols(id_proposicao = "c", 
                                                                  id_votacao = "i", voto = "i")) %>% 
    mutate(partido = padroniza_sigla(partido))
  
  orientacoes_governo <-
    adiciona_hierarquia_orientacao_governo(
      votos %>% filter(casa == "camara"),
      orientacoes %>% filter(toupper(partido) == "GOVERNO", casa == "camara")
    )
  
  orientacoes_partidos <- orientacoes %>% 
    filter(tolower(partido) != "governo" | casa == "senado") %>% 
    rbind(orientacoes_governo) %>% 
    group_by(partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    dplyr::mutate(id_partido = map_sigla_id(partido)) %>% 
    ungroup()
  
  orientacoes_alt <- orientacoes %>%
    filter(tolower(partido) != "governo" | casa == "senado") %>% 
    rbind(orientacoes_governo) %>% 
    select(id_votacao, partido, voto, casa) %>% 
    left_join(orientacoes_partidos %>% select(partido, id_partido), by = c("partido")) %>% 
    dplyr::mutate(id_votacao = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                      id_votacao)) %>% 
    select(id_votacao, id_partido, voto)
  
  return(orientacoes_alt)
}
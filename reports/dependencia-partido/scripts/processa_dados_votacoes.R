#' @title Lista com votos e orientações para as proposições votadas em plenário em 2019
#' @description Retorna os votos e as orientações dos partidos para as votações em 2019 
#' @return Lista contendo dois dataframes (votos e orientações)
#' @examples
#' votos_orientacao <- processa_dados_votacoes()
processa_dados_votacoes <- function(parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
                                    orientacoes_datapath = here::here("crawler/raw_data/orientacoes.csv"),
                                    votos_datapath = here::here("crawler/raw_data/votos.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/utils_votacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
  
  deputados <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara") %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  proposicoes_votadas <- fetch_proposicoes_votadas_por_ano_camara(2019) %>% 
    rbind(fetch_proposicoes_votadas_por_ano_camara(2020)) %>% 
    rbind(fetch_proposicoes_votadas_por_ano_camara(2021)) %>% 
    rbind(fetch_proposicoes_votadas_por_ano_camara(2022)) 
  
  votos <- read_csv(votos_datapath)
  
  orientacao <- read_csv(orientacoes_datapath)
  
  return(list(deputados, proposicoes_votadas, votos, orientacao))
}
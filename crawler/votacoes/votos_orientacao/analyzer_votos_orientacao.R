#' @title Processa votos e orientação de proposições votadas em plenário para um determinado ano
#' @description Recupera informação dos votos e das orientações dos partidos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @return Lista contendo dois dataframes: votos e orientações
#' @examples
#' votos_orientacao <- process_votos_orientacao(2019)
process_votos_orientacao <- function(ano = 2019) {
  
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/fetch_orientacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- fetch_votacoes_ano(ano)
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  votos <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_votacoes_por_ano, 
      2019
    )) %>% 
    unnest(dados) %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    distinct() 
  
  orientacao <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_orientacoes_por_proposicao, 
      2019
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(list(votos, orientacao))
}
#' @title Processa informações de votações que aconteceram em plenário a partir de uma lista de proposicões
#' @description Recupera informações como data e o objeto da votação
#' @param url Link para o csv com a lista de proposições
#' @return Dataframe contendo id da votação, objeto da votação, data, hora e código da sessão
#' @examples
#' processa_votacoes_info(url)
processa_votacoes_info <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSvvT0fmGUMwOHnEPe9hcAMC_l-u9d7sSplNYkMMzgiE_vFiDcWXWwl4Ys7qaXuWwx4VcPtFLBbMdBd/pub?gid=399933255&single=true&output=csv") {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  
  proposicoes_votadas <- read_csv(url, col_types = cols(id = "c")) %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    select(id)
    
  votacoes <- tibble(id = proposicoes_votadas$id) %>% 
    mutate(dados = purrr::map(
      id,
      fetch_votacoes_por_proposicao
    )) %>% 
    unnest(dados) %>% 
    mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>% 
    mutate(datetime = paste(data, hora)) %>%
    select(id_proposicao = id, id_votacao, objeto_votacao = obj_votacao, datetime, codigo_sessao = cod_sessao)
  
  return(votacoes)
}
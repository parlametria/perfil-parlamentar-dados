#' @title Processa informações de votações que aconteceram em plenário na Câmara a partir de uma lista de proposicões
#' @description Recupera informações como data e o objeto da votação
#' @param url Link para o csv com a lista de proposições
#' @return Dataframe contendo id da votação, objeto da votação, data, hora e código da sessão
#' @examples
#' processa_votacoes_info_camara(url)
processa_votacoes_info_camara <- function(url = NULL) {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))

  if (is.null(url)) {
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_CAMARA
  }
  
  proposicoes_votadas <- read_csv(url, col_types = cols(id = "c")) %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    select(id)
    
  votacoes <- tibble(id = proposicoes_votadas$id) %>% 
    mutate(dados = purrr::map(
      id,
      fetch_votacoes_por_proposicao_camara
    )) %>% 
    unnest(dados) %>% 
    mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>% 
    mutate(datetime = paste(data, hora)) %>%
    select(id_proposicao = id, id_votacao, objeto_votacao = obj_votacao, datetime, codigo_sessao = cod_sessao)
  
  return(votacoes)
}

#' @title Processa informações de votações que aconteceram em plenário do Senado a partir de uma lista de proposicões
#' @description Recupera informações como data e o objeto da votação
#' @param url Link para o csv com a lista de proposições
#' @return Dataframe contendo id da votação, objeto da votação, data, hora e código da sessão
#' @examples
#' processa_votacoes_info_senado(url)
processa_votacoes_info_senado <- function(url = NULL) {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/fetcher_votacoes_senado.R"))
  
  if (is.null(url)) {
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_SENADO
  }
  
  proposicoes_votadas <- read_csv(url, col_types = cols(id = "c")) %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    select(id)
  
  votacoes <- tibble(id = proposicoes_votadas$id) %>% 
    mutate(dados = purrr::map(
      id,
      fetcher_votacoes_por_proposicao_senado
    )) %>% 
    unnest(dados) %>% 
    mutate(id_votacao = codigo_sessao) %>% 
    select(id_proposicao = id, id_votacao, objeto_votacao, datetime, codigo_sessao)

  return(votacoes)
}

#' @title Processa informações de votações que aconteceram em plenário da Câmara e do Senado a partir de uma lista de proposicões
#' @description Recupera informações como data e o objeto da votação
#' @param url Link para o csv com a lista de proposições
#' @return Dataframe contendo id da proposição, id da votação, objeto da votação, data, hora e código da sessão
#' @examples
#' processa_votacoes_info()
processa_votacoes_info <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/proposicoes/utils_proposicoes.R"))
  
  votacoes_info_camara <- processa_votacoes_info_camara(.URL_PROPOSICOES_PLENARIO_CAMARA)
  
  votacoes_info_senado <- processa_votacoes_info_senado(.URL_PROPOSICOES_PLENARIO_SENADO)
  
  votacoes_info <- votacoes_info_camara %>% 
    rbind(votacoes_info_senado)
  
  return(votacoes_info)
}

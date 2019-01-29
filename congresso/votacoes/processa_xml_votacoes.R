library(XML)
library(tidyverse)
library(jsonlite)
library(RCurl)

#' @title Pega as votações da Câmara levantadas pela DIAP
#' @description Raspa as votações da Câmara levantadas pela DIAP, fornecidas em um pdf e convertido em xml, 
#' de acordo com um número da página
#' @param number Número da página onde se encontram as votações
#' @return Dataframe contendo link e id das votações da página passada como parâmetro
#' @examples
#' votacoes_por_pagina(50)
votacoes_por_pagina <- function(number){
  filter <- paste0("//page[@number ='", number,"']/text[a = 'por UF' or a  = 'por UF ']/a")
  nodes <- getNodeSet(xmltop, filter)
  votacoes <- sapply(nodes, xmlAttrs)
  votacoes <- votacoes %>% as.data.frame()
  if (nrow(votacoes) > 0) {
    colnames(votacoes) <- c('link_votacao')
    votacoes <-
      votacoes %>% 
      mutate(id_votacao = str_extract(link_votacao,'ideVotacao=[\\d]*'),
             id_votacao = str_extract(id_votacao, '(\\d).*'))
    
    votacoes$id_votacao <- as.numeric(votacoes$id_votacao)
    votacoes$link_votacao <- as.character(votacoes$link_votacao)
  } else {
    votacoes <-
      tribble(
        ~ link_votacao, ~ id_votacao, ~ numero)
  }
  return(votacoes)
}

#' @title Pega detalhes dass votações da Câmara levantadas pela DIAP
#' @description Exibe detalhes sobre as votações da câmara levantadas pela DIAP
#' @param link_votacao Link da votação 
#' @param id_votacao ID da votação  
#' @return Dataframe contendo link, id, titulo, tipo, id da proposição, 
#' placar de votos sim, não e abstenções da votação passada como parâmetro
#' @examples
#' votos_por_votacao('https://dadosabertos.camara.leg.br/api/v2/votacoes/6310', 6310)
votos_por_votacao <- function (link_votacao, id_votacao) {
  url = 'https://dadosabertos.camara.leg.br/api/v2/votacoes/'
  row <- as_tibble()
  
  if(!is.na(id_votacao)) {
    votacao <- (getURL(paste0(url, id_votacao)) %>% 
                  fromJSON())$dados
    
    if(!is.null(votacao)) {
      row <- 
        row %>% 
        summarise(
          link_votacao = dplyr::if_else(is.null(votacao$uri), 
                                        link_votacao, 
                                        votacao$uri),
          id_votacao = id_votacao,
          titulo = dplyr::if_else(is.null(votacao$titulo), 
                                  '', 
                                  votacao$titulo),
          tipo = dplyr::if_else(is.null(votacao$tipoVotacao), 
                                '', 
                                votacao$tipoVotacao),
          id_proposicao = dplyr::if_else(is.null(votacao$proposicao$id), 
                                         '', 
                                         toString(votacao$proposicao$id)),
          votos_sim = dplyr::if_else(is.null(votacao$placarSim),
                                     '', 
                                     toString(votacao$placarSim)),
          votos_nao = dplyr::if_else(is.null(votacao$placarNao), 
                                     '', 
                                     toString(votacao$placarNao)),
          votos_abstencao = dplyr::if_else(is.null(votacao$placarAbstencao), 
                                           '', 
                                           toString(votacao$placarAbstencao)))
      
      return(row)
    }
  }
    row <- 
      row %>% 
      summarise(
        link_votacao = link_votacao,
        id_votacao = NA,
        titulo = NA,
        tipo = NA,
        id_proposicao = NA,
        votos_sim = NA,
        votos_nao = NA,
        votos_abstencao = NA)
  return(row)
}

#' @title Pega informações dos votos dos parlamentares
#' @description Exibe detalhes sobre os votos dos parlamentares em uma determinada votação da câmara
#' @param id_votacao ID da votação  
#' @return Dataframe contendo link, id, titulo, tipo, id da proposição, 
#' placar de votos sim, não e abstenções da votação passada como parâmetro
#' @examples
#' processa_votacoes_detalhes(votacoes_df)
processa_votacoes_detalhes <- function(votacoes_df){
  votacoes_details <- 
    do.call("rbind", 
            purrr::map2_df(votacoes_df$link_votacao, votacoes_df$id_votacao, 
                           .f = ~ votos_por_votacao(.x, .y)))
  
  votacoes_details <- 
    votacoes_details %>% 
    t() %>% 
    as_tibble()
  
  votacoes_details$id_votacao <- as.numeric(votacoes_details$id_votacao)
  votacoes_details$id_proposicao <- as.numeric(votacoes_details$id_proposicao)
  votacoes_details$votos_sim <- as.numeric(votacoes_details$votos_sim)
  votacoes_details$votos_nao <- as.numeric(votacoes_details$votos_nao)
  votacoes_details$votos_abstencao <- as.numeric(votacoes_details$votos_abstencao)

  return(votacoes_details)
}

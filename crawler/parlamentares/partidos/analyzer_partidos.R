#' @title Recupera informações de um partido político
#' @description Recebe um id de partido e retorna os dados detalhados sobre ele
#' @param Id do partido
#' @return Dataframe de contendo informações sobre partidos
#' @examples
#' fetch_info_partido(55)
fetch_info_partido <- function(id) {
  print(paste0("Baixando informações do partido de id ", id))
  
  url <- paste0(
    "https://dadosabertos.camara.leg.br/api/v2/partidos/", id)
  
  info <- tryCatch({
    data <- (RCurl::getURI(url) %>%
               jsonlite::fromJSON())$dados
    
    data <- data %>%
      unlist() %>%
      t() %>%
      tibble::as_tibble()
    
    data <- data %>%
      dplyr::mutate(id = as.numeric(id),
                    tipo = "Partido")
    
    if (!"status.situacao" %in% names(data)) {
      data <- data %>%
        dplyr::mutate(status.situacao = "Ativo")
    }
    
    data <- data %>%
      dplyr::select(id,
                    sigla,
                    tipo,
                    situacao = status.situacao)
    
  }, error = function(e) {
    return(
      dplyr::tribble(~ id, ~ sigla, ~ tipo, ~ situacao)
      )
  })
  
  return(info) 
}

#' @title Recupera informações dos partidos políticos de uma legislatura
#' @description Recebe um id de legislatura e retorna os dados dos partidos políticos brasileiros dessa legislatura
#' @param Id da legislatura
#' @return Dataframe de partidos políticos de uma legislatura
#' @examples
#' fetch_partidos_por_leg(55)
fetch_partidos_por_leg <- function(legislatura = 56) {
  library(tidyverse)
  url <- 
    paste0("https://dadosabertos.camara.leg.br/api/v2/partidos?idLegislatura=", 
           legislatura, 
           "&itens=100")
  
  partidos <- tryCatch({
    data <- (RCurl::getURI(url) %>% 
      jsonlite::fromJSON())$dados
    
    data <- data %>% 
      dplyr::select(id)
    
  }, error = function(e) {
    return(
      dplyr::tribble(~ id, ~ sigla, ~ tipo, ~ situacao)
      )
  })
  
  if (nrow(partidos) > 0) {
    partidos <- 
      purrr::map_df(partidos$id, ~ fetch_info_partido(.x))
  }
  
  return(partidos %>% 
           dplyr::arrange(id))
  
}

#' @title Recupera informações dos blocos partidários de uma legislatura ou ativas na Câmara
#' @description Recebe um id de legislatura e retorna os dados dos blocos partidários brasileiros dessa legislatura, 
#' ou os que estão ativos, caso não seja passado nada
#' @param Id da legislatura
#' @return Dataframe dos blcoos partidários de uma legislatura ou atualmente ativos
#' @examples
#' fetch_blocos()
fetch_blocos <- function(legislatura = NULL) {
  library(tidyverse)
  
  if (!is.null(legislatura)) {
    url <- paste0("https://dadosabertos.camara.leg.br/api/v2/blocos?idLegislatura=", legislatura, "&itens=100")
  } else {
    url <- "https://dadosabertos.camara.leg.br/api/v2/blocos"
  }
  
  blocos <- tryCatch({
    data <- 
      (RCurl::getURI(url) %>% 
         jsonlite::fromJSON())$dados
    
    data <- data %>% 
      select(id, sigla = nome) %>% 
      mutate(
        tipo = "Bloco",
        situacao = "Ativo",
        id = as.numeric(id))
    
  }, error = function(e) {
    return(
      dplyr::tribble(~ id, ~ sigla, ~ tipo, ~ situacao)
    )
  })
  
  return(blocos %>% 
           dplyr::arrange(id))
}


#' @title Processa informações dos partidos políticos de uma ou mais legislaturas
#' @description Recebe um conjunto de ids de legislaturas e retorna os dados dos partidos políticos brasileiros dessas legislaturas e governo
#' @param Ids das legislaturas
#' @return Dataframe de partidos políticos das legislaturas e governo
#' @examples
#' process_partidos_por_leg(55)
process_partidos_por_leg <- function(legislaturas = c(55, 56)) {
  library(tidyverse)
  
  partidos <- 
    purrr::map_df(legislaturas, ~ fetch_partidos_por_leg(.x)) %>% 
    unique()
  
  blocos <- fetch_blocos()
  
  governo <- 
    dplyr::tribble(~ id, ~ sigla, ~ tipo, ~ situacao, 
                   0, "GOVERNO", "Governo", "Ativo",
                   1, "MAIORIA", "Maioria", "Ativo",
                   2, "MINORA", "Minoria","Ativo",
                   3, "OPOSIÇÃO", "Oposição","Ativo")
  
  partidos <- 
    dplyr::bind_rows(governo, partidos) %>% 
    dplyr::bind_rows(blocos) %>% 
    dplyr::mutate(sigla = gsub("\\.", "", sigla)) %>% 
    dplyr::arrange(id)
  
  return(partidos)
  
}

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
      dplyr::select(
        id,
        sigla, 
        situacao = status.situacao)
    
  }, error = function(e) {
    return(
      dplyr::tribble(~ id, ~ sigla, ~ situacao)
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
      dplyr::tribble(~ id, ~ sigla, ~ status)
      )
  })
  
  if (nrow(partidos) > 0) {
    partidos <- 
      purrr::map_df(partidos$id, ~ fetch_info_partido(.x))
  }
  
  return(partidos %>% 
           dplyr::arrange(id))
  
}

#' @title Processa informações dos partidos políticos de uma legislatura
#' @description Recebe um id de legislatura e retorna os dados dos partidos políticos brasileiros da legislatura e governo
#' @param Id da legislatura
#' @return Dataframe de partidos políticos de uma legislatura e governo
#' @examples
#' process_partidos_por_leg(55)
process_partidos_por_leg <- function(legislatura = 56) {
  partidos <- fetch_partidos_por_leg(legislatura)
  governo <- dplyr::tribble(~ id, ~ sigla, ~ situacao, 0, "GOV", "Ativo")
  
  partidos <- rbind(governo,partidos) %>% 
    dplyr::filter(situacao == "Ativo") %>% 
    dplyr::select(-situacao)
  
  return(partidos)
  
}
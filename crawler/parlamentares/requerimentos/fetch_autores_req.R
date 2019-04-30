library(tidyverse)
library(agoradigital)

get_info_autores <- function(uri_autor) {
  data <- (RCurl::getURI(uri_autor) %>% 
     jsonlite::fromJSON())$dados
  
  data <- data %>% 
    unlist() %>% t() %>% 
    tibble::as_tibble() %>% 
    dplyr::select(id, nome = ultimoStatus.nomeEleitoral)
  
  return(data)
}

get_uri_autores <- function(uri_autores, id_req) {
  data <- RCurl::getURL(uri_autores) %>% 
    jsonlite::fromJSON()
  data <- data$dados
  
  if (nrow(data) > 0 && !is.na(data$uri)) {
    autores <- purrr::map_df(data$uri, ~ get_info_autores(.x)) %>% 
      mutate(id_req = id_req)
    return (autores)
  }
}

fetch_autores_req <- function(prop_id, casa) {
  paste0("Baixando informações dos autores dos requerimentos da proposição ", prop_id, " na casa ", casa, "...") %>% 
    print()
  if (casa == 'camara') {
    reqs <- rcongresso::fetch_related_requerimentos_camara(prop_id, TRUE) %>% 
      dplyr::filter(!is.na(uri_autores))
    
    if (nrow(reqs) > 0) {
      df <- purrr::map2_df(reqs$uri_autores, reqs$id_req, ~ get_uri_autores(.x, .y))
      
      if (nrow(df) > 0) {
        return(df %>% 
                  dplyr::mutate(prop_id = prop_id, casa = casa) %>% 
                  dplyr::select(prop_id, casa, id_autor = id, nome, id_req))
      }
    }
  }
  
  return (dplyr::tribble(~ prop_id, ~ casa, ~ id_autor, ~ nome, ~ id_req))
}

fetch_all_autores_req <- function(tabela_votacoes_path = "crawler/raw_data/tabela_votacoes.csv") {
  tabela_votacoes <- readr::read_csv(tabela_votacoes_path)
  return(purrr::map2_df(tabela_votacoes$id_proposicao, tabela_votacoes$casa, ~ fetch_autores_req(.x, .y)))
}

reqs <- fetch_all_autores_req()

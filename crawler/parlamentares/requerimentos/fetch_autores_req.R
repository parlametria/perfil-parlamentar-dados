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

fetch_autores_req <- function(prop_id, casa, initial_date = lubridate::ymd_hm("2019-01-01 00:00")) {
  paste0("Baixando informações dos autores dos requerimentos da proposição ", prop_id, " na casa ", casa, "...") %>% 
    print()
  if (casa == 'camara') {
    reqs <- rcongresso::fetch_related_requerimentos_camara(prop_id, TRUE) 
    
    if (nrow(reqs) > 0) {
     reqs <- reqs %>% 
        dplyr::mutate(data_apresentacao = lubridate::ymd_hm(stringr::str_replace(data_apresentacao,"T"," "))) %>% 
        dplyr::filter(!is.na(uri_autores) & data_apresentacao >= initial_date)
     if (nrow(reqs) > 0) {
       df <- purrr::map2_df(reqs$uri_autores, 
                            reqs$id_req, 
                            ~ get_uri_autores(.x, .y) %>%
                              dplyr::left_join(reqs %>% 
                                                 dplyr::select(id_req, data_apresentacao), 
                                               by = "id_req"))
       
       if (nrow(df) > 0) {
         return(
           df %>%
             dplyr::mutate(prop_id = prop_id, 
                           casa = casa) %>% 
             dplyr::select(prop_id, casa, id_autor = id, nome, id_req, data = data_apresentacao)
         )
       }
     }
    }
  }
  
  return (dplyr::tribble(~ prop_id, ~ casa, ~ id_autor, ~ nome, ~ id_req, ~ data))
}

fetch_all_autores_req <- function(tabela_votacoes_path = "crawler/raw_data/tabela_proposicoes_leggo.csv") {
  tabela_votacoes <- readr::read_csv(tabela_votacoes_path) %>% 
    dplyr::filter(!is.na(id_camara)) %>% 
    dplyr::mutate(casa = "camara") %>% 
    dplyr::select(id_proposicao = id_camara, casa)
  return(purrr::map2_df(tabela_votacoes$id_proposicao, tabela_votacoes$casa, ~ fetch_autores_req(.x, .y)))
}

reqs <- fetch_all_autores_req()

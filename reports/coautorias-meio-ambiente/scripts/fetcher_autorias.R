library(tidyverse)

URL_PROPOSICOES <- "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
URL_AUTORES <- "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"
URL_API_PROPOSICOES <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes/"

get_dataset_parlamentares <- function(datapath) { 
  df <- readr::read_csv(datapath) %>%
    mutate(
      nome_eleitoral = 
        paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido) %>%
    mutate(id = as.character(id))
  
  return(df)
} 

get_dataset_autores <- function(datapath) {
  df <- readr::read_csv(datapath) %>% 
    group_by(id_req) %>% 
    mutate(n = n(),
           id = as.character(id)) %>% 
    filter(n > 1) %>% 
    select(-n) %>% 
    ungroup()
  
  return(df)
}

get_dataset_proposicoes <- function(datapath) {
  df <- read.csv(datapath, stringsAsFactors = F) %>%
    filter(!is.na(id_camara) & tema == 'Meio Ambiente') %>%
    select(-id_senado) %>%
    mutate(choice = apelido,
           id = as.character(id_camara))
  return(df)
}

fetch_relacionadas <- function(id) {
  url <-
    paste0(URL_API_PROPOSICOES,
           id,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id = as.character(id))   %>%
    select(id)
  
  if (nrow(ids_relacionadas) > 0) {
    ids_relacionadas <- ids_relacionadas %>% rbind(id)
    
  } else {
    ids_relacionadas <- dplyr::tribble(~ id, id)
    
  }
  
  return(ids_relacionadas %>%
           mutate(id = as.character(id)))
}

fetch_autores <- function(id) {
  print(paste0("Extraindo autores da proposição cujo id é ", id))
  
  url <-
    paste0(URL_API_PROPOSICOES,
           id,
           '/autores')
  
  autores <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id = as.character(id))   %>%
    filter(codTipo == 10000) 
  
  if (nrow(autores) == 0) {
    return(tribble(~ id, ~id_deputado))
  }
  
  autores <- autores %>% 
    mutate(id_deputado = stringr::str_extract(uri, '[\\d]*$')) %>% 
    select(id, id_deputado)
  
  return(autores)
}

fetch_all_autores <- function(proposicoes) {
  
  all_ids <- purrr::map_df(proposicoes$id, ~ fetch_relacionadas(.x)) %>% 
    distinct()
  
  autores <- purrr::map_df(all_ids$id, ~ fetch_autores(.x))
  
  autores <- autores %>% 
    rename(id_req = id, id = id_deputado) %>% 
    group_by(id_req) %>% 
    mutate(peso_arestas = 1/n())
  
  write_csv(autores, here::here("reports/coautorias-meio-ambiente/data/autores.csv"))
  
}



library(tidyverse)

URL_PROPOSICOES <- "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
URL_AUTORES <- "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"

fetch_csv <- function(url) {
  
  df <- 
    readr::read_delim(url, delim = ";")
  
  return(df)
}

fetch_relacionadas <- function(id) {
  url <-
    paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
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
  print(paste0("Extraindo autores de ", id))

  url <-
    paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
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

fetch_autores <- function(proposicoes) {
  
  all_ids <- purrr::map_df(proposicoes$id, ~ fetch_relacionadas(.x))
  
  autores <- purrr::map_df(all_ids$id, ~ fetch_autores(.x))
  
  autores <- process_autores(autores, parlamentares, all_ids)
  
  write_csv(autores, here::here("reports/coautorias-meio-ambiente/data/autores.csv"))
  
}
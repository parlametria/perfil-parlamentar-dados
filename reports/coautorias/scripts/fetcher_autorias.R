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

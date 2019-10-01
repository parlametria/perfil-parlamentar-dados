library(tidyverse)

URL <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes/"

fetch_relacionadas <- function(id_prop) {
  print(paste0("Baixando proposições relacionadas a ", id_prop, "..."))
  url <-
    paste0(URL,
           id_prop,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>% 
      rbind(id_prop) %>% 
    dplyr::mutate(id_ext = id_prop)
  
  return(ids_relacionadas)
}

fetch_all_relacionadas <- function(ids) {
  relacionadas <- purrr::map_df(ids, ~ fetch_relacionadas(.x)) %>% 
    dplyr::distinct()
  
  return(relacionadas)
}
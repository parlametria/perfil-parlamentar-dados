library(tidyverse)

URL <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes/"

get_dataset_parlamentares <- function(datapath) {
  df <- readr::read_csv(datapath) %>%
    mutate(nome_eleitoral =
             paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido) %>%
    mutate(id = as.character(id))
  
  return(df)
}

get_dataset_autores <- function(datapath) {
  df <- readr::read_csv(datapath, col_types = "ccd") %>%
    group_by(id_req) %>%
    mutate(n = n(),
           id = as.character(id)) %>%
    filter(n > 1) %>%
    select(-n) %>%
    ungroup()
  
  return(df)
}

fetch_autores <- function(id) {
  print(paste0("Extraindo autores da proposição cujo id é ", id))
  
  url <-
    paste0(URL,
           id,
           '/autores')
  
  autores <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id = as.character(id))   %>%
    filter(codTipo == 10000)
  
  if (nrow(autores) == 0) {
    return(tribble( ~ id, ~ id_deputado))
  }
  
  autores <- autores %>%
    mutate(id_deputado = stringr::str_extract(uri, '[\\d]*$')) %>%
    select(id, id_deputado)
  
  return(autores)
}

fetch_all_autores <- function(propositions) {
  autores <- purrr::map_df(propositions$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, id = id_deputado) %>%
    distinct() %>% 
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n())
  
  return(autores)
  
}

get_coautorias <- function(parlamentares, autores, relacionadas, min_peso) {
  
  autores <- autores %>% 
    filter(id_req %in% relacionadas$id_relacionada) %>% 
    distinct() %>% 
    mutate(id_req = as.character(id_req),
           id = as.character(id))
  
  coautorias <- autores %>%
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y)
  
  coautorias <- coautorias %>%
    remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id_req = as.character(id_req),
           id.x = as.character(id.x),
           id.y = as.character(id.y)) %>% 
    filter(peso_arestas >= min_peso)
  
  coautorias <- coautorias %>% 
    inner_join(parlamentares, by = c("id.x" = "id")) %>% 
    inner_join(parlamentares, by = c("id.y" = "id")) %>% 
    select(-c(sg_partido.x, sg_partido.y)) %>% 
    distinct()
  
  return(coautorias)
}

library(tidyverse)


#URL_AUTORES <-
#  "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"
URL_API_PROPOSICOES <-
  "https://dadosabertos.camara.leg.br/api/v2/proposicoes/"


fetch_csv <- function(url) {
  return(read_delim(url, delim = ";"))
}

get_dataset_parlamentares <- function(datapath) {
  df <- readr::read_csv(datapath) %>%
    mutate(nome_eleitoral =
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
    ungroup() %>% 
    mutate(id_req = as.character(id_req))
  
  return(df)
}

get_dataset_proposicoes <- function(datapath) {
  
  mpv_869_18 <- tribble(~siglaTipo, ~numero, ~ano, ~id,
                        "MPV", 869, 2018, 2190283)
  
  df <- read_delim(datapath, delim = ";") %>% 
    select(siglaTipo, numero, ano, id) %>% 
    bind_rows(mpv_869_18) %>% 
    filter(siglaTipo %in% c("PEC", "PL", "MPV")) %>% 
    mutate(choice = paste0(siglaTipo, " - ", numero, "/", ano),
           id = as.character(id))
  
  return(df)
}

get_dataset_coautorias <- function(datapath) {
  df <- read_csv(datapath, col_types = "cnccncc")
  return(df)
}

get_dataset_relacionadas <- function(datapath) {
  df <- read_csv(datapath, col_types = "cc")
  
}

fetch_relacionadas <- function(id_prop) {
  print(paste0("Baixando proposições relacionadas a ", id_prop, "..."))
  url <-
    paste0(URL_API_PROPOSICOES,
           id_prop,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id_relacionada = as.character(id),
           id_principal = as.character(id_prop)) %>%
    select(id_principal, id_relacionada)
  
  ids_relacionadas <-
    ids_relacionadas %>% rbind(dplyr::tribble( ~ id_relacionada, ~ id_principal, id_prop, id_prop)) %>%
    distinct()
  
  return(ids_relacionadas)
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
    return(tribble( ~ id, ~ id_deputado))
  }
  
  autores <- autores %>%
    mutate(id_deputado = stringr::str_extract(uri, '[\\d]*$')) %>%
    select(id, id_deputado)
  
  return(autores)
}

fetch_all_autores <- function(relacionadas) {
  autores <- purrr::map_df(relacionadas$id_relacionada, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, id = id_deputado) %>%
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n())
  
  write_csv(autores,
            here::here("reports/coautorias/data/autores.csv"))
  
}

get_coautorias <- function(parlamentares, autores, relacionadas = NULL, min_peso) {
  
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
  
  # write_csv(coautorias, here::here("reports/coautorias/data/coautorias.csv"))
  
  return(coautorias)
}


fetch_all_relacionadas <- function(ids) {
  relacionadas <- purrr::map_df(ids, ~ fetch_relacionadas(.x)) %>% 
    distinct()
  
  return(relacionadas)
}
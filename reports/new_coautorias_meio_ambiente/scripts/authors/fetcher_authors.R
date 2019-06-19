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
    paste0("https://www.camara.leg.br/proposicoesWeb/prop_autores?idProposicao=",
           id)
  
  autores <- tryCatch({
    data <- 
      httr::GET(url,
                httr::accept_json()) %>%
      httr::content('text', encoding = 'utf-8') %>%
      xml2::read_html()  %>%
      rvest::html_nodes('#content') %>% 
      rvest::html_nodes('span') %>% 
      rvest::html_text()
    
    res <- 
      purrr::map_df(data[3:length(data)], function(x) {
        return(tribble(~ id, ~ deputado, id, x))
    })
    
  }, error = function(e) {
    return(tribble( ~ id, ~ id_deputado))
  })

  return(autores)
}

fetch_all_autores <- function(proposicoes) {
  autores <- purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, nome_eleitoral = id_deputado) %>%
    distinct() %>% 
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n())
  
  return(autores)
  
}

get_coautorias <- function(parlamentares, autores, min_peso = 0.1) {
  coautorias <- autores %>%
    distinct() %>% 
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y) %>% 
    distinct()
  
  coautorias <- coautorias %>%
    remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id.x = as.character(id.x),
           id.y = as.character(id.y))
  
  coautorias <- coautorias %>% 
    inner_join(parlamentares, by = c("id.x" = "id")) %>% 
    inner_join(parlamentares, by = c("id.y" = "id")) %>% 
    select(-c(sg_partido.x, sg_partido.y)) %>% 
    distinct()
  
  return(coautorias)
}

mapeia_nome_para_id <- function(df, parlamentares) {
  parlamentares <- parlamentares %>% 
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral))
  
  df <- df %>% 
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral)) %>% 
    fuzzyjoin::regex_left_join(parlamentares, by = "nome_eleitoral_padronizado") %>% 
    filter(!is.na(sg_partido)) %>% select(id_req, id, nome_eleitoral = nome_eleitoral.y, sg_partido)
  
  return(df)
}


padroniza_nome <- function(nome) {
  return(
    toupper(nome) %>% 
      stringr::str_remove(' -.*')
  )
}

export_autores <- function(proposicoes, parlamentares) {
  autores <- fetch_all_autores(proposicoes) %>%
    mapeia_nome_para_id(parlamentares)
  
  return(autores)
}

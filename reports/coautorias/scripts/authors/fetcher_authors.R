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
      httr::content('text',
                    encoding = 'utf-8') %>%
      xml2::read_html()  %>%
      rvest::html_nodes('#content') %>%
      rvest::html_nodes('a') %>%
      rvest::html_attr("href") %>%
      as.data.frame() %>%
      filter(!is.na(.)) %>%
      mutate(id_deputado = stringr::str_extract(., "[\\d]+"),
             id = as.character(id))
    
    if (nrow(data) == 0) {
      return(tribble( ~ id, ~ id_deputado))
    }
  
    data <- data %>% 
      select(id, id_deputado)

  }, error = function(e) {
    return(tribble( ~ id, ~ id_deputado))
  })

  return(autores)
}

fetch_all_autores <- function(proposicoes) {
  autores <- purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, id = deputado) %>%
    distinct() %>% 
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n())
  
  return(autores)
  
}

get_coautorias <- function(parlamentares, autores, min_peso) {
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


#proposicoes = read_csv(here::here("reports/coautorias/data/proposicoes.csv"))
#autores_1 = fetch_all_autores(proposicoes %>% slice(0:6000))
#autores_2 = fetch_all_autores(proposicoes %>% slice(6001:12000))
#autores_3 = fetch_all_autores(proposicoes %>% slice(12001:18000))
#autores_4 = fetch_all_autores(proposicoes %>% slice(18001:24000))
#autores_5 = fetch_all_autores(proposicoes %>% slice(24001:nrow(proposicoes)))

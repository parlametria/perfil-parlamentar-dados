library(tidyverse)

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
        return(tribble( ~ id, ~ deputado, id, x))
      })
    
  }, error = function(e) {
    return(tribble(~ id, ~ deputado))
  })
  
  return(autores)
}

fetch_all_autores <- function(proposicoes, parlamentares) {
  autores <- purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, nome_eleitoral = deputado)
  
  autores <- autores %>%
    mapeia_nome_para_id(parlamentares) %>%
    distinct() %>%
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n()) %>%
    select(id_req, id, peso_arestas)
  
  return(autores)
}

get_coautorias <- function(parlamentares, autores) {
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
    distinct()
  
  return(coautorias)
}

mapeia_nome_para_id <- function(df, parlamentares) {
  parlamentares <- parlamentares %>%
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral))
  
  df <- df %>%
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral)) %>%
    left_join(parlamentares, by = "nome_eleitoral_padronizado") %>%
    filter(!is.na(sg_partido))
  
  return(df)
}

padroniza_nome <- function(nome) {
  return(toupper(nome) %>%
           stringr::str_remove('( -|<).*'))
}


paste_cols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = ":")
  }) %>%
    unlist())
}

remove_duplicated_edges <- function(df) {
  df %>%
    mutate(col_pairs =
             paste_cols(id.x,
                        id.y,
                        sep = ":")) %>%
    group_by(col_pairs) %>%
    tidyr::separate(col = col_pairs,
                    c("id.x",
                      "id.y"),
                    sep = ":") %>%
    group_by(id.x, id.y) %>%
    distinct()
}
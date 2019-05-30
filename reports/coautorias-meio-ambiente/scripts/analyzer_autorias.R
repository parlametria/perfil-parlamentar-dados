library(tidyverse)

get_coautorias <- function(id, autores, parlamentares) {
  if (typeof(id) == 'double') {
    relacionadas <- fetch_relacionadas(id)
    
  } else {
    relacionadas <-
      purrr::map_df(id$id, ~ fetch_relacionadas(.x))
  }
  
  autores <- autores %>% 
    filter(id_req %in% relacionadas$id) %>% 
    distinct() %>% 
    mutate(id_req = as.character(id_req),
           id = as.character(id)) %>% 
    filter(peso_arestas < 1)
  
  coautorias <- autores %>%
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y)
  
  coautorias <- coautorias %>%
    remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id_req = as.character(id_req))
  
  coautorias <- coautorias %>% 
    inner_join(parlamentares, by = c("id.x" = "id")) %>% 
    inner_join(parlamentares, by = c("id.y" = "id")) %>% 
    select(-c(sg_partido.x, sg_partido.y, id_req)) %>% 
    distinct()
  
  return(coautorias)
}
  
generate_nodes_and_edges <- function(min_peso, autores, parlamentares, coautorias) {
    coautorias <- coautorias %>% 
      filter(min_peso <= peso_arestas)
    
    nodes <- generate_nodes(autores, parlamentares, coautorias)
    
    edges <-
      generate_edges(coautorias %>% select(id.x, id.y, peso_arestas), nodes)
  
  return(list(nodes, edges))
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

add_url <- function(df) {
  link_para_detalhes_camara <-
    "https://www.camara.leg.br/proposicoesWeb/fichadetramitacao?idProposicao="
  
  df <- df %>%
    ungroup() %>% 
    mutate(
      url = 
        paste0(
          link_para_detalhes_camara,
          id_req)
    )
  
  return(df)
}

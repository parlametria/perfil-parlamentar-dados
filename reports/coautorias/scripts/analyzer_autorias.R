library(tidyverse)

env <- "dev"
path <- ''

if (env == "dev") {
  path = "reports/coautorias/"
} 

source(here::here(paste0(path, "scripts/fetcher_autorias.R")))

generate_nodes_and_edges <- function(autores, parlamentares, coautorias) {
  
  coautorias <- coautorias %>% 
    select(id.x, id.y, peso_arestas) %>% 
    distinct()
  
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

filter_coautorias <- function(ids, min_peso){
  coautorias <- get_dataset_coautorias(here::here(paste0(path, "data/coautorias.csv"))) %>% 
    filter(id_req %in% ids & peso_arestas >= min_peso) %>% 
    select(id.x, id.y, peso_arestas) %>% 
    distinct()
  
  return(coautorias)
}

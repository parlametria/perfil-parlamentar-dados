library(networkD3)
library(tidyverse)

generate_nodes <- function(
  df = readr::read_csv(here("reports/new_coautorias_meio_ambiente/data/autores.csv"), col_types = "ccc"), 
  parlamentares = readr::read_csv(here("reports/new_coautorias_meio_ambiente/data/parlamentares.csv"), col_types = "cccc"), 
  coautorias) {
  library(tidygraph)
  
  parlamentares_graph <- parlamentares %>% 
    mutate(nome_eleitoral = paste0('<strong>', nome_eleitoral, '</strong><br>', sg_partido, '/', uf)) %>% 
    select(-uf)
  
  df <- inner_join(df, parlamentares_graph, by="id") %>%
    group_by(id_req) %>%
    mutate(n = n()) %>%
    filter(n > 1) %>%
    ungroup() %>%
    distinct(id, nome_eleitoral, sg_partido)
  
  nodes <- df %>%
    ungroup() %>%
    tibble::rowid_to_column("index") %>%
    dplyr::mutate(id = as.character(id),
                  partido = as.factor(sg_partido)) %>%
    dplyr::select(index, id, nome_eleitoral, partido) %>%
    as.data.frame() %>%
    dplyr::mutate(index = index - 1)
  
  return(
    nodes
  )
}

generate_edges <- function(
  coautorias,
  nodes) {
  
  edges <- 
    coautorias %>% 
    ungroup() %>% 
    mutate(id.x=as.character(id.x),
           id.y=as.character(id.y))
  
  edges <- edges %>% 
    dplyr::group_by(id.x, id.y, novo_peso_arestas) %>% 
    dplyr::summarise(source = first(id.x), target = first(id.y)) %>% 
    ungroup() %>% 
    inner_join(nodes, by = c("source" = "id")) %>% 
    inner_join(nodes, by = c("target" = "id")) %>% 
    mutate(source = as.factor(source), target = as.factor(target)) %>% 
    select(source = index.x, target = index.y, novo_peso_arestas) %>% 
    arrange(target) %>% 
    as.data.frame()
  
  return(
    edges
  )
}

generate_graph <- function(nodes, edges) {

  fn <- forceNetwork(
    Links = edges, 
    Nodes = nodes,
    Source = "source", 
    Target = "target",
    Value = "novo_peso_arestas", 
    NodeID = "nome_eleitoral",
    Group ="partido", 
    zoom = T,
    linkColour = "#bfbdbd",
    fontFamily = "roboto",
    fontSize = 6,
    opacity = 0.8)
  return(fn)
}
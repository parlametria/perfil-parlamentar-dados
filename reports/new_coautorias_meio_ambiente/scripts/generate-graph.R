library(networkD3)
library(tidyverse)

generate_nodes <- function(df, parlamentares, coautorias) {
  library(tidygraph)
  
  df <- inner_join(df, parlamentares, by="id") %>%
    group_by(id_req) %>%
    mutate(n = n()) %>%
    filter(n > 1) %>%
    ungroup() %>%
    distinct(id, nome_eleitoral, sg_partido)
  # 
  # nodes <- df %>%
  #   ungroup() %>%
  #   tibble::rowid_to_column("index") %>%
  #   dplyr::mutate(id = as.character(id),
  #                 partido = as.factor(sg_partido),
  #                 index = index - 1) %>%
  #   dplyr::select(index, id, nome_eleitoral, partido) %>%
  #   as.data.frame()
  
  pre_nodes <- df %>%
    ungroup() %>%
    tibble::rowid_to_column("index") %>%
    dplyr::mutate(id = as.character(id),
                  partido = as.factor(sg_partido)) %>%
    dplyr::select(index, id, nome_eleitoral, partido) %>%
    as.data.frame()

  pre_links <- coautorias %>%
    dplyr::group_by(id.x, id.y) %>%
    dplyr::summarise(
      source = first(id.x),
      target = first(id.y),
      value = sum(peso_arestas)
    ) %>%
    ungroup() %>%
    inner_join(pre_nodes %>% select(index, id), by = c("source" = "id")) %>%
    inner_join(pre_nodes %>% select(index, id), by = c("target" = "id")) %>%
    mutate(source = as.factor(source), target = as.factor(target)) %>%
    select(source = index.x, target = index.y, value) %>%
    arrange(target) %>%
    as.data.frame()

  graph <- tbl_graph(nodes = pre_nodes,
                     edges = pre_links,
                     directed = F)

  pre_nodes <- graph %>%
    mutate(group = as.factor(group_edge_betweenness())) %>%
    as.data.frame() %>%
    group_by(group) %>%
    filter(n() > 1) %>%
    ungroup() %>%
    select(-index) %>%
    tibble::rowid_to_column("index")

  nodes <- pre_nodes %>%
    dplyr::mutate(index = index - 1)
  
  return(
    nodes
  )
}

generate_edges <- function(df, nodes) {
  df <- 
    df %>% 
    ungroup() %>% 
    mutate(id.x=as.character(id.x),
           id.y=as.character(id.y))
  return(
    df %>% 
      dplyr::group_by(id.x, id.y, peso_arestas) %>% 
      dplyr::summarise(source = first(id.x), target = first(id.y)) %>% 
      ungroup() %>% 
      inner_join(nodes, by = c("source" = "id")) %>% 
      inner_join(nodes, by = c("target" = "id")) %>% 
      mutate(source = as.factor(source), target = as.factor(target)) %>% 
      select(source = index.x, target = index.y, peso_arestas) %>% 
      arrange(target) %>% 
      as.data.frame()
  )
}

generate_graph <- function(nodes, edges) {

  fn <- forceNetwork(
    Links = edges, 
    Nodes = nodes,
    Source = "source", 
    Target = "target",
    Value = "peso_arestas", 
    NodeID = "nome_eleitoral",
    Group ="partido", 
    zoom = T,
    linkColour = "#bfbdbd",
    fontFamily = "roboto",
    opacity = 0.8)
  return(fn)
}
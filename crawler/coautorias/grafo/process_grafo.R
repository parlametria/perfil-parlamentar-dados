library(networkD3)
library(tidyverse)
library(tidygraph)

#' @title Gera os nodes e edges da rede de coautorias
#' @description Gera os nodes e edges da rede de coautorias
#' @param autores Dataframe de autores
#' @param parlamentares Dataframe de parlamentares
#' @param coautorias Dataframe de coautorias
#' @return Retorna uma lista com nodes e edges da rede de coautorias
generate_nodes_and_edges <- function(autores, parlamentares, coautorias) {
  source(here::here("reports/new_coautorias_meio_ambiente/scripts/generate-graph.R"))
  coautorias <- coautorias %>% 
    select(id.x, id.y, peso_arestas) %>% 
    distinct()
  
  nodes <- .generate_nodes(autores, parlamentares, coautorias)
  
  edges <-
    .generate_edges(coautorias %>% select(id.x, id.y, peso_arestas), nodes)
  
  return(list(nodes = nodes, edges = edges))
}

#' @title Gera os nodes da rede de coautorias
#' @description Gera os nodes da rede de coautorias
#' @param df Dataframe de autores
#' @param parlamentares Dataframe de parlamentares
#' @param coautorias Dataframe de coautorias
#' @return Retorna um dataframe com os nodes da rede de coautorias
.generate_nodes <- function(df, parlamentares, coautorias) {
  df <- inner_join(df, parlamentares, by="id") %>%
    group_by(id_req) %>%
    mutate(n = n()) %>%
    filter(n > 1) %>%
    ungroup() %>%
    distinct(id, nome_eleitoral, sg_partido)
  
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


#' @title Gera as edges da rede de coautorias
#' @description Gera as edges da rede de coautorias
#' @param df Dataframe de coautorias
#' @param nodes Dataframe de nodes
#' @return Retorna dataframe com as edges da rede de coautorias
.generate_edges <- function(df, nodes) {
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

#' @title Gera o grafo da rede de coautorias
#' @description Gera o grafo da rede de coautorias
#' @param nodes Dataframe de nodes
#' @param edges Dataframe de edges
#' @return Retorna grafo da rede de coautorias
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
    fontSize = 6,
    opacity = 0.8)
  return(fn)
}
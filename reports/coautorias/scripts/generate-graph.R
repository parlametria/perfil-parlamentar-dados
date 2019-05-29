library(networkD3)
library(tidyverse)

generate_nodes <- function(df) {
  return(
    df %>%
      dplyr::distinct(id, nome_eleitoral, sg_partido) %>%
      tibble::rowid_to_column("index") %>%
      dplyr::mutate(index = index - 1,
                    id = as.character(id),
                    group = as.factor(sg_partido)) %>%
      dplyr::select(index, id, nome_eleitoral, group) %>% 
      as.data.frame()
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
      dplyr::group_by(id.x, id.y) %>% 
      dplyr::summarise(source = first(id.x), target = first(id.y), peso=sum(peso_arestas)) %>% 
      ungroup() %>% 
      mutate(source = as.factor(source), target = as.factor(target)) %>% 
      left_join(nodes, by = c("source" = "id")) %>% 
      left_join(nodes, by = c("target" = "id")) %>% 
      select(source = index.x, target = index.y, peso) %>% 
      arrange(target) %>% 
      as.data.frame()
  )
}

generate_graph <- function(nodes, edges) {
  fn <- forceNetwork(
    Links = edges, Nodes = nodes,
    Source = "source", Target = "target",
    Value = "peso", NodeID = "nome_eleitoral",
    Group ="group",Nodesize = "peso_total_autor",
    opacity = 0.8, zoom = T,
    linkColour = "#808080")
  
  return(fn)
}

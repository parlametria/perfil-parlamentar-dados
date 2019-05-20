library(networkD3)
library(tidyverse)

generateNodes <- function(df) {
  return(
    df %>%
      dplyr::distinct(id, nome_eleitoral, sg_partido) %>%
      tibble::rowid_to_column("index") %>%
      dplyr::mutate(index = index - 1,
                    id = as.character(id),
                    group = as.factor(sg_partido)) %>%
      as.data.frame()
  )
}

generateEdges <- function(df, nodes) {
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
      mutate(source = as.factor(source), target = as.factor(target)) %>% 
      left_join(nodes, by = c("source" = "id")) %>% 
      left_join(nodes, by = c("target" = "id")) %>% 
      select(source = index.x, target = index.y, peso_arestas) %>% 
      arrange(target) %>% 
      as.data.frame()
  )
}

library(networkD3)
library(tidyverse)

generate_graph <- function(df, output_file) {
  nodes <- df %>% 
    dplyr::select(nome, id_req, prop_id) %>% 
    dplyr::group_by(nome) %>% 
    dplyr::summarise(size = n()) %>% 
    dplyr::mutate(group = 1, nome = as.factor(nome)) %>% 
    tibble::rowid_to_column("index") %>% 
    dplyr::mutate(index = index - 1) %>% 
    dplyr::select(index, nome, group) %>% 
    as.data.frame()
  
  links <- df %>% full_join(df, by = "id_req") %>%
    filter(id_autor.x != id_autor.y) %>% 
    dplyr::select(-c(prop_id.x, casa.x, prop_id.y, casa.y)) %>% 
    dplyr::group_by(id_autor.x, id_autor.y) %>% 
    dplyr::summarise(source = first(nome.x), target = first(nome.y), value = n()) %>% 
    ungroup() %>% 
    mutate(source = as.factor(source), target = as.factor(target)) %>% 
    left_join(nodes %>% select(index, nome), by = c("source" = "nome")) %>% 
    left_join(nodes %>% select(index, nome), by = c("target" = "nome")) %>% 
    select(source = index.x, target = index.y, value) %>% 
    arrange(target) %>% 
    as.data.frame()
  
  # Plot
  fn <- forceNetwork(Links = links, Nodes = nodes,
                     Source = "source", Target = "target",
                     Value = "value", NodeID = "nome",
                     Group = "group", opacity = 0.8, zoom = T)
  fn %>% 
    saveNetwork(output_file)
}

library(tidyverse)
library(tidygraph)
library(ggraph)

reqs <- read.csv(here::here("crawler/raw_data/autores_requerimentos_leggo.csv")) %>% 
  dplyr::select(-prop_id, -casa) %>% 
  distinct()

a <- links <- reqs %>% 
  full_join(reqs, by = "id_req") %>%
  filter(id_autor.x != id_autor.y) %>% 
  select(-c(id_autor.x, id_autor.y))

as <- tidygraph::as_tbl_graph(a)

as %>% 
  mutate(community = as.factor(group_infomap(trials = 2))) %>% 
  ggraph(layout = 'kk') + 
  geom_edge_link(aes(alpha = ..index..), show.legend = FALSE) + 
  geom_node_point(aes(colour = community), size = 7) + 
  theme_graph()

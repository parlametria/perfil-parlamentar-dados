library(tidyverse)
library(networkD3)

pasteCols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = ":")
  }) %>%
    unlist())
}

removeDuplicatedEdges <- function(df) {
  df %>%
    mutate(col_pairs =
             pasteCols(id.x,
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

generateEdges <- function(autores, proposicoes) {
  df <- 
    left_join(autores, proposicoes, by = c("id_req" = "id")) %>%
    group_by(id_req) %>% 
    mutate(n = n()) %>% 
    filter(!is.na(id) & n > 1) %>% 
    select(-n) %>% 
    ungroup()
  
  links <- df %>%
    full_join(df, by = "id_req") %>%
    filter(nome.x != nome.y) %>%
    removeDuplicatedEdges() %>%
    distinct(id.x, id.y, id_req) %>% 
    ungroup()
  
  autores <- autores %>% 
    group_by(nome) %>% 
    mutate(id = as.character(id),
           partido = first(partido),
           uf = first(uf)) %>%
    ungroup() %>% 
    group_by(id) %>% 
    mutate(nome = first(nome),
           nome = paste0(nome, ' - ', partido, '/', uf)) %>% 
    select(-id_req) %>%
    distinct(id, nome) %>% 
    filter(!is.na(id))
  
  edges <- autores %>%
    dplyr::right_join(links, by = c("id" = "id.x"), keep = TRUE) %>% 
    dplyr::distinct() %>% 
    dplyr::rename(id.x = id)
  
  edges <- autores %>%
    dplyr::inner_join(edges, by = c("id" = "id.y")) %>% 
    dplyr::rename(id.y = id.x,
                  id.x = id) %>% 
    dplyr::distinct(id.x, nome.x, id.y, nome.y, id_req)
  
  return(edges)
}

proposicoes <- read_csv(here::here("crawler/raw_data/proposicoes_2019.csv"))
autores <- read_csv(here::here("crawler/raw_data/autores_proposicoes_2019.csv"))

edges <- generateEdges(autores, proposicoes) %>% 
  dplyr::group_by(id.x, id.y, id_req) %>%
  dplyr::mutate(weight = 1 / n()) %>% 
  filter(weight >= 0.50)

write_csv(edges, here::here("crawler/raw_data/pares_autorias.csv"))

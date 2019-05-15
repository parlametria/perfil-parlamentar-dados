library(tidyverse)
library(networkD3)

source(here::here("crawler/autorias/fetcher_autores_2019.R"))
source(here::here("crawler/autorias/fetcher_proposicoes_2019.R"))

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

processaAutores <- function(autores, proposicoes) {
  df <- autores %>% 
    full_join(autores, by = "id_req") %>%
    filter(id.x != id.y) %>% 
    removeDuplicatedEdges() %>% 
    distinct() 
  
  df <- 
    inner_join(df, proposicoes, by = c("id_req" = "id")) %>%
    group_by(id_req) %>% 
    mutate(n_autores = n(),
           peso_aresta = 1 / n_autores) %>% 
    ungroup() %>% 
    filter(peso_aresta >= 0.1)
  
  return(df)
}

exportaParesAutorias <- function() {
  proposicoes <- exportaProposicoes()
  autores <- exportaAutoresProposicoes()
  
  df <- processaAutores(autores, proposicoes)
  
  write_csv(df, here::here("crawler/raw_data/pares_autorias.csv"))
}


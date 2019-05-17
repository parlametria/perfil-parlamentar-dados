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
  autores <- 
    autores %>% 
    group_by(id_req) %>% 
    mutate(num_autores = n(),
           peso_arestas = 1/num_autores)
  
  # df <- autores %>% 
  #   full_join(autores, by = c("id_req", "num_autores", "peso_arestas")) %>%
  #   filter(id.x != id.y) %>% 
  #   removeDuplicatedEdges() %>% 
  #   distinct() 
  
  df <- 
    inner_join(autores, proposicoes, 
               by = c("id_req" = "id"))
  
  return(df)
}

exportaParesAutorias <- function() {
  proposicoes <- exportaProposicoes() %>% 
    filter(!is.na(numero) & !is.na(siglaTipo) & !is.na(ano) &ano != 0) %>% 
    select(id,
           descricao = descricaoTipo,
           urlInteiroTeor)
  autores <- exportaAutoresProposicoes()
  
  df <- processaAutores(autores, proposicoes)
  
  write_csv(df, here::here("crawler/raw_data/autorias.csv"))
  return(df)
}


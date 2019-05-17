library(tidyverse)
library(networkD3)

paste_cols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = ":")
  }) %>%
    unlist())
}

removeDuplicatedEdges <- function(df) {
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

fetcher_autores <- function() {
  url <- 
    "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"
  
  df <- 
    readr::read_delim(url, delim = ";")
  # processaProposicoesAutores()
  
  return(df)
}

fetcher_proposicoes <- function() {
  url <- 
    "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
  
  df <- 
    readr::read_delim(url, delim = ";")
  
  return(df)
}


processa_autores_proposicoes <- function(autores, proposicoes) {
  autores <- 
    autores %>% 
    group_by(idProposicao) %>% 
    mutate(num_autores = n(),
           peso_arestas = 1/num_autores)
  
  # df <- autores %>% 
  #   full_join(autores, by = c("id_req", "num_autores", "peso_arestas")) %>%
  #   filter(id.x != id.y) %>% 
  #   removeDuplicatedEdges() %>% 
  #   distinct() 
  
  df <- 
    inner_join(autores, proposicoes, 
               by = c("idProposicao" = "id"))
  
  return(df)
}

analyzer_autores_proposicoes <- function() {
  proposicoes <- fetcher_proposicoes() %>% 
    filter(!is.na(numero) & !is.na(siglaTipo) & !is.na(ano) & ano != 0) %>% 
    select(id,
           descricao = descricaoTipo,
           siglaTipo, 
           numero,
           ano)
  
  autores <- fetcher_autores()
  
  df <- processa_autores_proposicoes(autores, proposicoes) %>% 
    select(id_req = idProposicao, id = idDeputadoAutor, peso_arestas) %>% 
    filter(!is.na(id))
  
  df <- df %>% 
    full_join(df, by=c("id_req", "peso_arestas")) %>% 
    filter((id.x != id.y & peso_arestas != 1) | (peso_arestas == 1))
  
 # write_csv(df, here::here("crawler/raw_data/autorias.csv"))
  return(list(df, proposicoes))
}


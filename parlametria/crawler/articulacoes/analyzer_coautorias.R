#' @title Gera dataframe com os coautores de proposições
#' @description A partir de um conjunto de proposições, retorna um dataframe de coautores dessas proposições.
#' @param proposicoes Dataframe dos parlamentares
#' @return Dataframe contendo informações sobre as coautores
get_coautores <- function(proposicoes) {
  library(tidyverse)
  
  source(here::here("parlametria/crawler/articulacoes/fetcher_authors.R"))
  
  autores <- fetch_all_autores(proposicoes) %>%
    distinct() %>%
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n()) %>%
    select(id_req, id, peso_arestas)
  
  coautorias <- autores %>%
    distinct() %>%
    filter(peso_arestas < 1) %>% 
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y) %>%
    distinct()
  
  return(coautorias)
}

#' @title Gera dataframe de coautorias
#' @description A partir de um conjunto de parlamentares e proposições,
#' retorna um dataframe de coautorias, onde cada linha representa um par de deputados
#' que coautoraram em proposições.
#' @param proposicoes Dataframe de proposições contendo coluna id
#' @param parlamentares Dataframe dos parlamentares
#' @return Dataframe contendo informações sobre as coautorias
get_coautorias <- function(proposicoes, 
                           parlamentares = readr::read_csv(here::here("crawler/raw_data/parlamentares.csv"),
                                                           col_types = readr::cols(id = "c"))) {
  library(tidyverse)
  
  coautorias <-
    get_coautores(proposicoes) %>%
    remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id.x = as.character(id.x),
           id.y = as.character(id.y))
  
  coautorias <- coautorias %>%
    inner_join(parlamentares, by = c("id.x" = "id")) %>%
    inner_join(parlamentares, by = c("id.y" = "id")) %>%
    distinct()
  
  return(coautorias)
}

#' @title Gera dataframe de coautorias
#' @description A partir de um conjunto de parlamentares e autores de proposições,
#' retorna um dataframe de coautorias, onde cada linha representa um par de deputados
#' que coautoraram em proposições
#' @return Dataframe contendo informações sobre as coautorias
#' @param parlamentares Dataframe dos parlamentares
#' @param autores Dataframe dos autores de proposições
get_lista_articulacoes <- function(proposicoes,
                                   parlamentares = readr::read_csv(here::here("crawler/raw_data/parlamentares.csv"),
                                                                   col_types = readr::cols(id = "c"))) {
  library(tidyverse)
  
  coautorias <- 
    get_coautores(proposicoes) %>%
    inner_join(parlamentares, by = c("id.x" = "id")) %>%
    inner_join(parlamentares, by = c("id.y" = "id")) %>%
    distinct()
  
  return(coautorias)
}

#' @title Concateca dois elementos com um separador no meio
#' @description Recebe duas variáveis x e y e retorna a união "x:y".
#' @param x Primeira variável a ser concatenada
#' @param y Segunda variável a ser concatenada
#' @param sep Separador a ser concatenado
#' @return String concatenada com a primeira variável + separador + segunda variável
paste_cols <- function(x, y, sep = ":") {
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i) {
    paste0(sort(c(x[i], y[i])), collapse = sep)
  }) %>%
    unlist())
}

#' @title Remove pares duplicados
#' @description Recebe um dataframe com pares repetidos em ordens diferentes (x e y, y e x) e
#' remove a repetição.
#' @param df Dataframe contendo os pares duplicados
#' @return Dataframe com pares únicos
remove_duplicated_edges <- function(df) {
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

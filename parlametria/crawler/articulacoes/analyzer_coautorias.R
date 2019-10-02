#' @title Gera dataframe com os coautores de proposições
#' @description A partir de um conjunto de proposições, retorna um dataframe de coautores dessas proposições.
#' @param proposicoes Dataframe das proposições contendo coluna id
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

#' @title Gera dataframe de coautorias com pares de parlamentares repetidos mas em diferentes ordens (x e y, y e x)
#' @description A partir de um conjunto de proposições e parlamentares,
#' retorna um dataframe de coautorias, onde há uma linha representa para o par de parlamentares x e y e
#' outra para y e x (mesmos dados, ordens diferentes).
#' @param proposicoes Dataframe das proposições com coluna id
#' @param parlamentares Dataframe dos parlamentares
#' @return Dataframe contendo informações sobre as coautorias
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

#' @title Gera dataframe de coautorias de um parlamentar específico
#' @description A partir de um id de parlamentar,
#' retorna um dataframe de coautorias, onde cada linha representa coautorias em
#' proposições do parlamentar.
#' @param id_parlamentar ID do parlamentar
#' @return Dataframe contendo informações sobre as coautorias
coautorias_by_parlamentar <- function(id_parlamentar) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/proposicoes/fetcher_propoposicoes_camara.R"))
  source(here("parlametria/crawler/articulacoes/fetcher_authors.R"))
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(.default = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, nome_eleitoral, sg_partido, uf)
  
  proposicoes <- fetch_proposicoes_por_autor(id_parlamentar)
  
  relacionadas <- fetch_all_relacionadas(proposicoes$id)
  
  coautorias <- get_coautorias(relacionadas, parlamentares)
  
  coautorias <- coautorias %>% 
    filter(id.x == id_parlamentar | id.y == id_parlamentar) %>% 
    mutate(peso_arestas = round(peso_arestas, 2),
           nome_eleitoral.x = paste0(nome_eleitoral.x, " - ", sg_partido.x, "/", uf.x),
           nome_eleitoral.y = paste0(nome_eleitoral.y, " - ", sg_partido.y, "/", uf.y)) %>% 
    select(-c(sg_partido.x, sg_partido.y, uf.x, uf.y))
  
  return(coautorias)
}

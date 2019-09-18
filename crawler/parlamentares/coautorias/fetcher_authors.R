library(tidyverse)

#' @title Recupera dados de autores de uma proposição 
#' @description Recupera dados de autores de proposições a partir do id da proposição, 
#' raspando da página web da câmara
#' @param id ID da proposição
#' @return Dataframe contendo informações sobre os autores da proposição
#' @examples
#' fetch_autores(2121442)
fetch_autores <- function(id_prop) {
  print(paste0("Extraindo autores da proposição cujo id é ", id_prop))
  
  url <-
    paste0("https://www.camara.leg.br/proposicoesWeb/prop_autores?idProposicao=",
           id_prop)
  
  autores <- tryCatch({
    data <-
      httr::GET(url,
                httr::accept_json()) %>%
      httr::content('text', encoding = 'utf-8') %>%
      xml2::read_html()  %>%
      rvest::html_nodes('#content') %>%
      rvest::html_nodes('a') %>% 
      rvest::html_attr("href") %>% 
      as.data.frame()
    
    data <- 
      data %>% mutate(id_req = id_prop, 
                      id_deputado = str_extract(., "\\d.*")) %>% 
      filter(!is.na(id_deputado)) %>% 
      select(id_req, id = id_deputado)
    
  }, error = function(e) {
    return(tribble(~ id_req, ~ id))
  })
  
  return(autores)
}

#' @title Recupera todos os autores de um conjunto de proposições que estão no conjunto de parlamentares
#' @description Recupera dados de autores de proposições a partir do conjunto de ids das proposições 
#' e que estão no dataframe de parlamentares
#' @param proposicoes Dataframe das proposições contendo uma coluna "id"
#' @param proposicoes Dataframe dos parlamentares
#' @return Dataframe contendo informações sobre os autores da proposição
fetch_all_autores <- function(proposicoes, parlamentares) {
  autores <- purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    distinct() %>%
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n()) %>%
    select(id_req, id, peso_arestas)
  
  return(autores)
}

#' @title Gera dataframe de coautorias
#' @description A partir de um conjunto de parlamentares e autores de proposições,
#' retorna um dataframe de coautorias, onde cada linha representa um par de deputados
#' que coautoraram em proposições
#' @return Dataframe contendo informações sobre as coautorias
#' @param parlamentares Dataframe dos parlamentares
#' @param autores Dataframe dos autores de proposições
get_coautorias <- function(parlamentares, autores) {
  coautorias <- autores %>%
    distinct() %>%
    filter(peso_arestas < 1) %>% 
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y) %>%
    distinct()
  
  coautorias <- coautorias %>%
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

#' @title Mapeia nome para id de autores de proposições
#' @description A partir de um conjunto de parlamentares e autores de proposições,
#' adiciona uma coluna id correspondente ao nome do parlamentar
#' @return Dataframe contendo nova coluna "id"
#' @param autores Dataframe dos autores de proposições
#' @param parlamentares Dataframe dos parlamentares
mapeia_nome_para_id <- function(autores, parlamentares) {
  library(tidyverse)
  source(here::here("crawler/utils/utils.R"))
  
  parlamentares <- parlamentares %>%
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral))
  
  df <- autores %>%
    mutate(nome_eleitoral_padronizado = padroniza_nome(nome_eleitoral)) %>%
    left_join(parlamentares, by = "nome_eleitoral_padronizado") %>%
    filter(!is.na(sg_partido))
  
  return(df)
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
library(tidyverse)

#' @title Recupera informações dos autores de uma proposição
#' @description Retorna dados dos autores de uma proposição
#' @param id ID da proposição
#' @return Dataframe com lista de autores de uma proposição
fetch_autores <- function(id) {
  print(paste0("Extraindo autores da proposição cujo id é ", id))
  
  url <-
    paste0("https://www.camara.leg.br/proposicoesWeb/prop_autores?idProposicao=",
           id)
  
  autores <- tryCatch({
    data <- 
      httr::GET(url,
                httr::accept_json()) %>%
      httr::content('text', encoding = 'utf-8') %>%
      xml2::read_html()  %>%
      rvest::html_nodes('#content') %>% 
      rvest::html_nodes('span') %>% 
      rvest::html_text()
    
    res <- 
      purrr::map_df(data[3:length(data)], function(x) {
        return(tribble(~ id, ~ deputado, id, x))
      })
    
  }, error = function(e) {
    return(tribble( ~ id, ~ deputado))
  })
  
  return(autores)
}

#' @title Recupera informações dos autores de um conjunto de proposições
#' @description Retorna dados dos autores de um conjunto de proposições
#' @param proposicoes Dataframe com coluna 'id' das proposições
#' @param parlamentares Dataframe contendo informações dos parlamentares
#' @return Dataframe com lista de autores de um conjunto de proposições
fetch_all_autores <- function(proposicoes, parlamentares) {
  autores <- purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  autores <- autores %>%
    rename(id_req = id, nome_eleitoral = deputado)
  
  autores <- autores %>% 
    .mapeia_nome_para_id(parlamentares) %>% 
    distinct() %>% 
    group_by(id_req) %>%
    mutate(peso_arestas = 1 / n()) %>% 
    select(id_req, id, peso_arestas)
  
  return(autores)
}

#' @title Mapeia nome eleitoral de parlamentar para ID
#' @description Mapeia nome eleitoral de parlamentar para ID
#' @param df Dataframe de autores
#' @param parlamentares Dataframe de parlamentares
#' @return Dataframe com id mapeado
.mapeia_nome_para_id <- function(df, parlamentares) {
  parlamentares <- parlamentares %>% 
    mutate(nome_eleitoral_padronizado = .padroniza_nome(nome_eleitoral))
  
  df <- df %>% 
    mutate(nome_eleitoral_padronizado = .padroniza_nome(nome_eleitoral)) %>% 
    left_join(parlamentares, by = "nome_eleitoral_padronizado") %>% 
    filter(!is.na(sg_partido))
  
  return(df)
}

#' @title Padroniza nome eleitoral
#' @description Recebe um nome e processa-o, retirando
#' caracteres especiais e colocando para lowercase
#' @param nome Nome a ser processado
#' @return Nome processado
.padroniza_nome <- function(nome) {
  return(
    toupper(nome) %>% 
      stringr::str_remove('( -|<).*')
  )
}

#' @title Recupera dados de autores de uma proposição 
#' @description Recupera dados de autores de proposições a partir do id da proposição, 
#' raspando da página web da câmara
#' @param id ID da proposição
#' @return Dataframe contendo informações sobre os autores da proposição
#' @examples
#' fetch_autores(2121442)
fetch_autores <- function(id_prop) {
  library(tidyverse)
  
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
  library(tidyverse)
  
  autores <- 
    purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  return(autores)
}
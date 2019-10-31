#' @title Recupera dados de autores de uma proposição 
#' @description Recupera dados de autores de proposições a partir do id da proposição, 
#' raspando da página web da câmara
#' @param id_prop ID da proposição
#' @return Dataframe contendo informações sobre os autores da proposição
#' @examples
#' fetch_autores(2121442)
fetch_autores <- function(id_prop) {
  Sys.sleep(3)
  
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
    print(e)
    return(tribble(~ id_req, ~ id))
  })
  
  return(autores)
}

#' @title Recupera todos os autores de um conjunto de proposições
#' @description Recupera dados de autores de proposições a partir do conjunto de ids das proposições 
#' @param proposicoes Dataframe das proposições contendo uma coluna "id"
#' @return Dataframe contendo informações sobre os autores da proposição
fetch_all_autores <- function(proposicoes) {
  library(tidyverse)
  
  autores <- 
    purrr::map_df(proposicoes$id, ~ fetch_autores(.x))
  
  return(autores)
}

#' @title Recupera dados de autores de uma proposição no Senado
#' @description Recupera dados de autores de uma proposição no Senado usando a API de dados abertos do Senado
#' @param id_proposicao ID da proposição
#' @return Dataframe contendo informações sobre os autores da proposição
#' @examples
#' fetch_autores_senado(136904)
fetch_autores_senado <- function(id_proposicao) {
  library(tidyverse)
  library(here)
  
  url <- paste0("http://legis.senado.leg.br/dadosabertos/materia/", id_proposicao)
  
  autores <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Autoria/Autor") %>%
      map_df(function(x) {
        list(
          id_proposicao = id_proposicao,
          id = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/CodigoParlamentar") %>% 
            xml2::xml_text(),
          nome = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/NomeParlamentar") %>% 
            xml2::xml_text(),
          partido = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/SiglaPartidoParlamentar") %>% 
            xml2::xml_text(),
          uf = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/UfParlamentar") %>% 
            xml2::xml_text()
        )
      })
    
  }, error = function(e) {
    print(e)
    data <- tribble(~ id, ~ nome, ~ partido, ~ uf)
    return(data)
  })
  
  return(autores)
}

#' @title Recupera todos os autores de um conjunto de proposições do senado
#' @description Recupera dados de autores de proposições do senado a partir do conjunto de ids das proposições
#' @param proposicoes Dataframe das proposições do senado contendo uma coluna "id"
#' @return Dataframe contendo informações sobre os autores da proposição do senado
#' @examples 
#' autores_proposicao_senado <- fetch_all_autores_senado(proposicoes)
fetch_all_autores_senado <- function(proposicoes) {
  library(tidyverse)
  
  autores <- 
    purrr::map_df(proposicoes$id, ~ fetch_autores_senado(.x))
  
  return(autores)
}

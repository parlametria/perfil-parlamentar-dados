#' @title Recupera informações dos partidos e blocos presentes no Senado Federal
#' @description Recupera lista de partidos e blocos que atualmente possuem lideranças no Senado
#' @return Dataframe de contendo informações sobre partidos e blocos
#' @examples
#' partidos_senado <- fetch_partidos_senado()
fetch_partidos_senado <- function() {
  library(tidyverse)
  library(here)
  
  url <- "https://legis.senado.leg.br/dadosabertos/plenario/lista/liderancas"
  
  tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    
    bloco_partidos <- xml2::xml_find_all(xml, ".//Lideranca") %>%
      map_df(function(x) {
        list(
          nome_lideranca = xml2::xml_find_first(x, ".//NomeUnidLideranca") %>%
            xml2::xml_text(),
          sigla_lideranca = xml2::xml_find_first(x, ".//SiglaUnidLideranca") %>%
            xml2::xml_text(),
          cod_lideranca = xml2::xml_find_first(x, ".//CodigoUnidPartd") %>%
            xml2::xml_text()
        )
      })
    
    partidos <- xml2::xml_find_all(xml, ".//Lideranca/Partidos/Partido") %>%
      map_df(function(x) {
        list(
          nome_lideranca = xml2::xml_find_first(x, ".//NomeUnidLideranca") %>%
            xml2::xml_text(),
          sigla_lideranca = xml2::xml_find_first(x, ".//SiglaUnidLideranca") %>%
            xml2::xml_text(),
          cod_lideranca = xml2::xml_find_first(x, ".//CodigoUnidLideranca") %>%
            xml2::xml_text()
        )
      })
    
    partidos_senado <- bloco_partidos %>% 
      rbind(partidos) %>% 
      mutate(tipo = if_else(str_detect(sigla_lideranca, "Governo|Maioria|Minoria|Bloco"), 
                            sigla_lideranca,
                            "Partido")) %>% 
      mutate(situacao = "Ativo") %>% 
      mutate(sigla = if_else(str_detect(sigla_lideranca, "Bloco"), 
                            nome_lideranca, 
                            sigla_lideranca)) %>% 
      select(id = cod_lideranca, sigla, tipo, situacao)
    
  }, error = function(e) {
    data <- tribble(~ id, ~ sigla, ~ tipo, ~ situacao)
    return(data)
  })
  
  return(partidos_senado)
}
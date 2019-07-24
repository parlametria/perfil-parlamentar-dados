#' @title Recupera as informações sobre lideranças de blocos e partidos no Senado
#' @description Retorna um dataframe contendo os líderes, vice-líderes e representantes dos blocos e partidos
#' no Senado Federal
#' @return Dataframe contendo lideranças dos blocos e partidos no Senado Federal
#' @examples
#' liderancas <- fetch_liderancas_senado()
fetch_liderancas_senado <- function() {
  library(tidyverse)
  library(here)
  
  url <- "http://legis.senado.leg.br/dadosabertos/plenario/lista/liderancas"
  
  tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    
    liderancas_bloco <- xml2::xml_find_all(xml, ".//Lideranca/Parlamentares/Parlamentar") %>%
      map_df(function(x) {
        list(
          nome_lideranca = xml2::xml_find_first(x, "..//..//NomeUnidLideranca") %>%
            xml2::xml_text(),
          sigla_lideranca = xml2::xml_find_first(x, "..//..//SiglaUnidLideranca") %>%
            xml2::xml_text(),
          cargo = xml2::xml_find_first(x, ".//TipoLideranca") %>%
            xml2::xml_text(),
          id = xml2::xml_find_first(x, ".//CodigoParlamentar") %>%
            xml2::xml_text(),
          nome = xml2::xml_find_first(x, ".//NomeParlamentar") %>%
            xml2::xml_text(),
          partido = xml2::xml_find_first(x, ".//SiglaPartido") %>%
            xml2::xml_text(),
          uf = xml2::xml_find_first(x, ".//SiglaUf") %>%
            xml2::xml_text()
        )
      }) %>% 
      mutate(bloco_partido = if_else(str_detect(sigla_lideranca, "Bloco"), 
                                     nome_lideranca, 
                                     sigla_lideranca)) %>% 
      select(bloco_partido, cargo, id, nome, partido, uf)
    
    liderancas_partido <- xml2::xml_find_all(xml, ".//Lideranca/Partidos/Partido/Parlamentares/Parlamentar") %>%
      map_df(function(x) {
        list(
          bloco_partido = xml2::xml_find_first(x, "..//..//SiglaUnidLideranca") %>%
            xml2::xml_text(),
          cargo = xml2::xml_find_first(x, ".//TipoLideranca") %>%
            xml2::xml_text(),
          id = xml2::xml_find_first(x, ".//CodigoParlamentar") %>%
            xml2::xml_text(),
          nome = xml2::xml_find_first(x, ".//NomeParlamentar") %>%
            xml2::xml_text(),
          partido = xml2::xml_find_first(x, ".//SiglaPartido") %>%
            xml2::xml_text(),
          uf = xml2::xml_find_first(x, ".//SiglaUf") %>%
            xml2::xml_text()
        )
      }) %>% 
      select(bloco_partido, cargo, id, nome, partido, uf)
    
    liderancas <- liderancas_bloco %>% 
      rbind(liderancas_partido) %>% 
      mutate(bloco_partido = if_else(str_detect(bloco_partido, "LIDERANÇA DO GOVERNO"), 
                                     "Governo",
                                     bloco_partido)) %>% 
      mutate(casa = "senado")
    
  }, error = function(e) {
    data <- tribble(~ bloco_partido, ~ cargo, ~ id, ~ nome, ~ partido, ~ uf, ~ casa)
    return(data)
  })
  
  return(liderancas)
}

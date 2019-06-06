#' @title Importa dados de todos os senadores de uma legislatura específica
#' @description Importa os dados de todos os senadores de uma legislatura específica
#' @param legislatura Legislatura para recuperação da lista de senadores
#' @return Dataframe contendo informações dos senadores: id, nome civil, uf, partido, genero, dentre outras
#' @examples
#' senadores <- fetch_senadores_legislatura(56)
fetch_senadores_legislatura <- function(legislatura = 56) {
  library(tidyverse)
  
  url <- paste0("http://legis.senado.leg.br/dadosabertos/senador/lista/legislatura/", legislatura)
  
  senadores <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Parlamentar") %>%
      map_df(function(x) {
        list(
          id = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/CodigoParlamentar") %>% 
            xml2::xml_text(),
          nome_eleitoral = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/NomeParlamentar") %>% 
            xml2::xml_text(),
          nome_civil = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/NomeCompletoParlamentar") %>% 
            xml2::xml_text(),
          genero = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/SexoParlamentar") %>%
            xml2::xml_text(),
          uf = xml2::xml_find_first(x, ".//Mandatos/Mandato/UfParlamentar") %>%
            xml2::xml_text(),
          sg_partido = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/SiglaPartidoParlamentar") %>%
            xml2::xml_text(),
          condicao_eleitoral = xml2::xml_find_first(x, ".//Mandatos/Mandato/DescricaoParticipacao") %>%
            xml2::xml_text(),
          legislatura = legislatura
        )
      }) %>% 
      dplyr::distinct()
  }, error = function(e) {
    data <- tribble(
      ~ id, ~ nome_eleitoral, ~ nome_civil, ~ genero, ~ uf,
      ~ sg_partido, ~ condicao_eleitoral, ~ legislatura)
    return(data)
  })
  
  return(senadores)
}

#' @title Importa dados de todos os senadores atualmente em exercício no Senado
#' @description Importa os dados de todos os senadores atualmente em exercício no Senado
#' @param legislatura_atual Número da legislatura atual
#' @return Dataframe contendo informações dos senadores: id, nome eleitoral, legislatura atual
#' @examples
#' senadores <- fetch_senadores_atuais()
fetch_senadores_atuais <- function(legislatura_atual = 56) {
  library(tidyverse)
    
  url <- paste0("http://legis.senado.leg.br/dadosabertos/senador/lista/atual")
  
  senadores <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Parlamentar") %>%
      map_df(function(x) {
        list(
          id = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/CodigoParlamentar") %>% 
            xml2::xml_text(),
          nome_eleitoral = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/NomeParlamentar") %>% 
            xml2::xml_text(),
          legislatura_atual = 56,
          em_exercicio = 1
        )
      })
  }, error = function(e) {
    data <- tribble(
      ~ id, ~ nome_eleitoral, ~ legislatura_atual, ~ em_exercicio)
    return(data)
  })
  
  return(senadores)
}

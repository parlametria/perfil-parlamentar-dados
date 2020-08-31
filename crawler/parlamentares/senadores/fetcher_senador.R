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
    xml <- RCurl::getURL(url, .encoding = "Windows-1252") %>% xml2::read_xml()
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
    
    dados_senador <- pmap_dfr(
      list(data %>% distinct(id) %>% pull(id)),
      ~ fetch_info_por_senador(..1)) %>% 
      select(id, data_nascimento)
    
    data <- data %>% 
      left_join(dados_senador, by = c("id"))
    
  }, error = function(e) {
    print(e)
    data <- tribble(
      ~ id, ~ nome_eleitoral, ~ nome_civil, ~ genero, ~ uf,
      ~ sg_partido, ~ condicao_eleitoral, ~ legislatura, ~ data_nascimento)
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
    xml <- RCurl::getURL(url, .encoding = "Windows-1252") %>% xml2::read_xml()
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
    print(e)
    data <- tribble(
      ~ id, ~ nome_eleitoral, ~ legislatura_atual, ~ em_exercicio)
    return(data)
  })
  
  return(senadores)
}

#' @title Importa dados particulares de um senador a partir da API de dados abertos do Senado
#' @description Captura informações individuais dos senadores disponíveis apenas no endpoint específico para o Senador
#' @param id_senador ID do senador na API de dados abertos do Senado
#' @return Dataframe contendo informações do senador como nome e data de nascimento
#' @examples
#' contarato <- fetch_info_por_senador(5953)
fetch_info_por_senador <- function(id_senador) {
  library(tidyverse)
  
  print(paste0("Baixando informações do Senador ", id_senador))
  url <- paste0("http://legis.senado.leg.br/dadosabertos/senador/", id_senador)
  
  senador <- tryCatch({
    xml <- RCurl::getURL(url, .encoding = "Windows-1252") %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Parlamentar") %>%
      map_df(function(x) {
        list(
          id = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/CodigoParlamentar") %>% 
            xml2::xml_text(),
          nome_eleitoral = xml2::xml_find_first(x, ".//IdentificacaoParlamentar/NomeParlamentar") %>% 
            xml2::xml_text(),
          data_nascimento = xml2::xml_find_first(x, ".//DadosBasicosParlamentar/DataNascimento") %>% 
            xml2::xml_text() ## yyyy-mm-dd
        )
      }) %>% 
      dplyr::distinct()
  }, error = function(e) {
    print(e)
    data <- tribble(
      ~ id, ~ nome_eleitoral, ~ data_nascimento)
    return(data)
  })
  
  return(senador)
}

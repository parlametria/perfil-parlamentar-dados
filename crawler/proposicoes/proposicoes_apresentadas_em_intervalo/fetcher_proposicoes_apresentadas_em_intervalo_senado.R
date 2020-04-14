#' @title Recupera dados das proposições que foram apresentadas em
#' um intervalo de datas.
#' @description Recebe uma data inicial e uma data final, retorna as 
#' proposições apresentadas no intervalo.
#' @param data_inicial Data inicial do intervalo (formato AAAAMMDD)
#' @param data_final Data final do intervalo (formato AAAAMMDD)
#' @return Dataframe com lista de proposições apresentadas em um intervalo
#' de datas.
fetcher_proposicoes_em_intervalo_senado <-
  function(data_inicial = "20200311",
           data_final = gsub("-", "", Sys.Date())) {
    library(tidyverse)
    
    url <-
      paste0(
        "http://legis.senado.leg.br/dadosabertos/materia/pesquisa/lista?dataInicioApresentacao=",
        data_inicial,
        "&dataFimApresentacao=",
        data_final
      )
    
    proposicoes <- tryCatch({
      xml <- RCurl::getURL(url) %>% xml2::read_xml()
      data <- xml2::xml_find_all(xml, ".//Materia") %>%
        map_df(function(x) {
          list(
            id = xml2::xml_find_first(x, ".//IdentificacaoMateria/CodigoMateria") %>%
              xml2::xml_text(),
            sigla_tipo = xml2::xml_find_first(x, ".//IdentificacaoMateria/SiglaSubtipoMateria") %>%
              xml2::xml_text(),
            numero = xml2::xml_find_first(x, ".//IdentificacaoMateria/NumeroMateria") %>%
              xml2::xml_text(),
            ano = xml2::xml_find_first(x, ".//IdentificacaoMateria/AnoMateria") %>%
              xml2::xml_text()
          )
        })
      
      data <- data %>%
        mutate(numero = as.numeric(numero),
               ano = as.numeric(ano))
    }, error = function(e) {
      print(e)
      data <- tribble(~ id, ~ sigla_tipo, ~ numero, ~ ano)
      return(data)
    })
    
    return(proposicoes)
  }

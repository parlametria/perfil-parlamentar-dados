#' @title Recupera informações das votações nominais do plenário em um intervalo de tempo
#' @description A partir de uma data de início e uma de fim, recupera dados de
#' votações nominais de plenário que aconteceram na Senado Federal
#' @param initial_date Data inicial do período de votações. Formato: "dd/mm/yyyy"
#' @param end_date Data final do período de votações. Formato: "dd/mm/yyyy"
#' @return Votações da proposição em um intervalo de tempo
#' @examples
#' votacoes <- fetcher_votacoes_por_intervalo_senado()
fetcher_votacoes_por_intervalo_senado <-
  function(initial_date = "01/02/2019",
           end_date = format(Sys.Date(), "%d/%m/%Y")) {
    library(tidyverse)
    library(rvest)
    
    url <-
      paste0(
        "https://www25.senado.leg.br/web/atividade/votacoes-nominais/-/v/periodo/",
        initial_date,
        "/a/",
        end_date
      )
    
    votacoes <- tryCatch({
      dados <-
        RCurl::getURI(url) %>%
        xml2::read_html() %>%
        html_nodes(".table") %>%
        
        purrr::map_df(function(x) {
          rows <-
            html_nodes(x, "tbody") %>%
            html_nodes("tr")
          
          if (length(rows) > 0) {
            data <-
              purrr::map_df(rows, function(y) {
                list(
                  objeto_votacao = (html_nodes(y, "td")[2]) %>%
                    html_text(),
                  
                  link_votacao =
                    (html_nodes(y, "td") %>%
                       html_nodes("a") %>%
                       html_attr("href")
                    )[1],
                  
                  votacao_secreta = 
                    if_else(
                      str_detect(
                        (html_nodes(y, "td")[1]) %>%
                          html_text(), 
                        "votação secreta"),
                      1, 
                      0)
                )
              }) %>%
              mutate(
                link_votacao =
                  stringr::str_remove_all(link_votacao,
                                          '&p_order_by=.*'),
                
                id_proposicao =
                  extract_number_from_regex(link_votacao,
                                            "p_cod_materia_i=[\\d]*&"),
                
                id_votacao =
                  extract_number_from_regex(link_votacao,
                                            "p_cod_sessao_votacao_i=.*"),
                
                datetime =
                  extract_data(x, "caption")
              ) %>% 
              select(id_proposicao, 
                     id_votacao, 
                     objeto_votacao, 
                     datetime, 
                     votacao_secreta, 
                     link_votacao)
            
            return(data)
          }
          
          return(tribble())
          
        })
      
      return(dados)
      
    }, error = function(e) {
      return(tribble( ~ id_proposicao,
                      ~ id_votacao,
                      ~ objeto_votacao,
                      ~ datetime,
                      ~ votacao_secreta,
                      ~ link_votacao))
    })
    
    return(votacoes)
  }

#' @title Recupera informações das votações nominais do plenário de uma proposição
#' @description A partir do id de uma proposição, recupera dados de
#' votações nominais de plenário que aconteceram na Senado Federal
#' @param id_proposicao Id da proposição
#' @param ano Ano que filtra as proposições. Caso seja null, todas as votações serão retornadas
#' @return Votações de uma proposição em um ano ou todos, caso nenhum ano seja passado como parâmetro
#' @examples
#' votacoes <- fetcher_votacoes_por_proposicao_senado(id_proposicao = 135251)
fetcher_votacoes_por_proposicao_senado <-
  function(id_proposicao, ano = NULL) {
    library(tidyverse)
    library(xml2)
    
    print(paste0("Capturando votações da proposição ", id_proposicao))
    
    url <-
      paste0("http://legis.senado.leg.br/dadosabertos/materia/votacoes/",
             id_proposicao)
    
    xml <-
      RCurl::getURI(url)
    
    votacoes <- tryCatch({
      data <-
        xml %>%
        read_xml() %>%
        xml_find_all(".//Materia/Votacoes/Votacao") %>%
        map_df(function(x) {
          list(
            codigo_sessao =
              xml_find_first(x, "./CodigoSessaoVotacao") %>%
              xml_text(),
            objeto_votacao =
              xml_find_first(x, "./DescricaoVotacao") %>%
              xml_text(),
            data =
              xml_find_first(x, "./SessaoPlenaria/DataSessao") %>%
              xml_text(),
            hora =
              xml_find_first(x, "./SessaoPlenaria/HoraInicioSessao") %>%
              xml_text()
          )
        }) %>%
        mutate(datetime =
                 paste0(data,
                        " ",
                        hora),
               id_proposicao = id_proposicao) %>%
        select(id_proposicao,
               objeto_votacao,
               datetime,
               codigo_sessao)

      if (!is.null(ano)) {
        data <- data %>%
          filter(lubridate::year(datetime) == ano)
      }
      data
    }, error = function(e) {
      print(e)
      data <- (tribble( ~ id_proposicao,
                      ~ objeto_votacao,
                      ~ datetime,
                      ~ codigo_sessao))
    })
    
    return(votacoes)
  }

#' @title Extrai somente os números de um texto extraído de regex
#' @description A partir de uma expressão regular, extrai o texto desse regex e depois retorna apenas os números existentes
#' @param text Texto onde o regex será aplicado
#' @param text_regex Expressão regular onde o texto será extraído para depois serem retornados apenas os números
#' @return Números existentes em um texto extraído a partir de uma expressão regular
#' @examples
#' extract_number_from_regex("p_cod_materia_i=[\\d]*&")
extract_number_from_regex <- function(text, text_regex) {
  return(stringr::str_extract(text, text_regex) %>%
           stringr::str_extract("[\\d]+"))
}

#' @title Extrai data no formato "dd/mm/yyyy" de uma tag dentro de um xml_nodeset html
#' @description A partir de um nó xml_nodeset, extrai o texto da tag e recupera uma data no formato "dd/mm/yyyy"
#' @param x xml_nodeset contendo a tag a ser extraída
#' @param tag tag html que possui a data
#' @return Data extraída no formato "yyyy-mm-dd"
#' @examples
#' extract_data(x, "caption")
extract_data <- function(x, tag) {
  rvest::html_nodes(x, tag) %>%
    rvest::html_text() %>%
    stringr::str_extract("[\\d]{2}/[\\d]{2}/[\\d]{4}") %>%
    lubridate::dmy() %>% 
    return()
}

#' @title Recupera dados das proposições que foram apresentadas
#' em uma página da API, em dado intervalo de datas e o número de itens.
#' @description Recebe um número de página, uma data inicial,
#' uma data final e a quantidade de itens a retornar de
#' proposições apresentadas. (Máximo de 100)
#' @param pagina página da API que se deseja acessar
#' @param data_inicial Data inicial do intervalo (formato AAAA-MM-DD)
#' @param data_final Data final do intervalo (formato AAAA-MM-DD)
#' @param itens número de itens que se deseja retornar
#' @return Dataframe com lista de proposições apresentadas em um intervalo
#' de datas, na página e número de itens selecionados.
fetch_proposicoes_por_pagina <-
  function(pagina, data_inicial, data_final, itens = 100) {
    library(tidyverse)
    
    cat(
      paste0(
        "Baixando a página ",
        pagina,
        " de proposições apresentadas entre ",
        data_inicial,
        " e ",
        data_final,
        "...\n"
      )
    )
    
    url <-
      paste0(
        "https://dadosabertos.camara.leg.br/api/v2/proposicoes?dataApresentacaoInicio=",
        data_inicial,
        "&dataApresentacaoFim=",
        data_final,
        "&pagina=",
        pagina,
        "&itens=",
        itens
      )
    
    proposicoes <- tryCatch({
      data <-
        (RCurl::getURI(url) %>%
           jsonlite::fromJSON())$dados
      
      data <- data %>%
        select(id, sisgla_tipo = siglaTipo, numero, ano)
      
    }, error = function(e) {
      return(tribble(~ id, ~ sigla_tipo, ~ numero, ~ ano))
    })
    
    return(proposicoes)
  }

#' @title Recupera dados das proposições que foram apresentadas em
#' um intervalo de datas e o número de itens por página.
#' @description Recebe uma data inicial, uma data final e a
#' quantidade de itens a retornar de proposições apresentadas por
#' página. (Máximo de 100)
#' @param data_inicial Data inicial do intervalo (formato AAAA-MM-DD)
#' @param data_final Data final do intervalo (formato AAAA-MM-DD)
#' @param itens número de itens que se deseja retornar
#' @return Dataframe com lista de proposições apresentadas em um intervalo
#' de datas com o número de itens por página selecionado.
fetcher_proposicoes_em_intervalo_camara <-
  function(data_inicial = "2020-03-11",
           data_final = Sys.Date(),
           itens = 100) {
    library(tidyverse)
    
    url <-
      paste0(
        "https://dadosabertos.camara.leg.br/api/v2/proposicoes?dataApresentacaoInicio=",
        data_inicial,
        "&dataApresentacaoFim=",
        data_final,
        "&itens=",
        itens
      )
    
    proposicoes <- tryCatch({
      links <- (RCurl::getURI(url) %>%
                  jsonlite::fromJSON())$links
      
      num_pags <- links %>%
        filter(rel == "last") %>%
        pull(href) %>%
        str_extract("&pagina=[\\d]*&") %>%
        str_extract("[\\d]+")
      
      paginas <- seq(1, num_pags)
      
      data <-
        purrr::map_df(paginas,
                      ~ fetch_proposicoes_por_pagina(.x, data_inicial, data_final, itens))
      
      data <- data %>%
        dplyr::distinct(id, .keep_all = TRUE)
      
    }, error = function(e) {
      return(tribble(~ id, ~ sigla_tipo, ~ numero, ~ ano))
    })
    
    return(proposicoes)
  }
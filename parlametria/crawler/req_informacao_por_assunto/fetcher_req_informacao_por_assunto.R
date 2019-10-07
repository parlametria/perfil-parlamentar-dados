#' @title Retorna os autores de proposições sobre determinados assuntos, ano e tipo de proposição
#' @description Recebe o tipo da proposição (SIGLA), o ano e os termos de busca do filtro e retorna 
#' os autores das proposições encontradas.
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param terms Termos da buca
#' @return Dataframe dos autores das proposições encontradas.
fetch_req_informacao_autores_camara <- function(tipo_proposicao = "RIC",
                                         ano = 2019,
                                         terms = c('agricultura', 'meio ambiente')) {
  library(tidyverse)
  
  source(here::here("parlametria/crawler/articulacoes/fetcher_authors.R"))
  
  proposicoes <-
    purrr::map_df(terms, ~ filter_proposicoes_by_term_camara(tipo_proposicao, ano, .x))
  
  autores <- fetch_all_autores(proposicoes)
  
  autores_summarised <- autores %>%
    distinct() %>% 
    group_by(id) %>%
    summarise(num_req_informacao = n())
  
  return(autores_summarised)
}
#' @title Retrona as proposições da busca
#' @description Recebe um tipo de proposição, o ano e o termo de busca e monta a requisição à API da Câmara e 
#' retorna os ids das proposições filtradas.
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param terms Termos da buca
#' @return Conjunto de ID das proposições filtradas
filter_proposicoes_by_term_camara <- function(tipo_proposicao, ano, terms) {
  library(tidyverse)
  library(httr)
  
  proposicoes <- tryCatch({
    body_args <-
      list(
        order = "relevancia",
        pagina = 1,
        q = terms,
        ano = ano,
        tiposDeProposicao = tipo_proposicao
      )
    
    data <-
      POST(
        url = "https://www.camara.leg.br/api/v1/busca/proposicoes/_search",
        body = jsonlite::toJSON(body_args, auto_unbox = TRUE),
        add_headers("Content-Type" = "application/json")
      ) %>%
      content()
    
    # Descobre o número de páginas
    itens_por_pagina <- length(data$hits$hits)
    num_paginas <- data$hits$total / itens_por_pagina 
    
    if (num_paginas %% 1 != 0) {
      num_paginas = as.integer(num_paginas) + 1
    }
    
    proposicoes <-
      purrr::map_df(
        seq(1, num_paginas),
        ~ filter_proposicoes_by_term_and_page_camara(tipo_proposicao, ano, terms, .x)
      )
    
    proposicoes
  }, error = function(e) {
    tribble(~ id)
  })
  
  return(proposicoes)
}

#' @title Retrona as proposições da busca
#' @description Recebe um tipo de proposição, o ano, o termo de busca e a página e monta a requisição à API da Câmara e 
#' retorna os ids das proposições filtradas.
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param terms Termos da buca
#' @param pag Página da requisição
#' @return Conjunto de ID das proposições filtradas por página
filter_proposicoes_by_term_and_page_camara <- function(tipo_proposicao, ano, terms, pag) {
  library(tidyverse)
  library(httr)
  
  id_proposicoes <- tryCatch({
    body_args <-
      list(
        order = "relevancia",
        pagina = pag,
        q = terms,
        ano = ano,
        tiposDeProposicao = tipo_proposicao
      )
    
    data <-
      POST(
        url = "https://www.camara.leg.br/api/v1/busca/proposicoes/_search",
        body = jsonlite::toJSON(body_args, auto_unbox = TRUE),
        add_headers("Content-Type" = "application/json")
      ) %>%
      content()
    
    id_proposicoes <-
      purrr::map_df(data$hits$hits, function(x) {
        id = x %>%
          as.data.frame() %>%
          pull(X_id)
        return(tibble(id = id) %>% 
                 mutate(id = as.character(id)))
      })
    
    id_proposicoes
  }, error = function(e) {
    return(tribble(~ id))
  })

  return(id_proposicoes)
}

#' @title Retrona as proposições da busca
#' @description Recebe um tipo de proposição, o ano e o termo de busca e monta a requisição à API do Senado e 
#' retorna informaçẽos sobre as proposições filtradas
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param term {String} Termos da busca. Use aspas para definir restrição de termos com mais de uma palavra
#' @return Conjunto de ID das proposições filtradas
#' @example requerimentos_ministra_agricultura <- filter_proposicoes_by_term_senado(term = '"Ministra da Agricultura"')
filter_proposicoes_by_term_senado <- function(
  tipo_proposicao = "req", 
  ano = 2019, 
  term = '"Ministra da Agricultura"|"Ministra de Estado da Agricultura"|"Ministro do Meio Ambiente"|"Ministro de Estado do Meio Ambiente"') {
  
  library(tidyverse)
  library(here)
  
  term <- URLencode(term, reserved = TRUE)
  
  url <- paste0("http://legis.senado.leg.br/dadosabertos/materia/pesquisa/lista",
                "?sigla=", tipo_proposicao,
                "&ano=", ano,
                "&palavraChave=", term)
  
  requerimentos <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Materia") %>%
      map_df(function(x) {
        list(
          id = xml2::xml_find_first(x, ".//IdentificacaoMateria/CodigoMateria") %>% 
            xml2::xml_text(),
          numero = xml2::xml_find_first(x, ".//IdentificacaoMateria/DescricaoIdentificacaoMateria") %>% 
            xml2::xml_text(),
          ementa = xml2::xml_find_first(x, ".//DadosBasicosMateria/EmentaMateria") %>% 
            xml2::xml_text()
        )
      })
    
  }, error = function(e) {
    print(e)
    data <- tribble(~ id, ~ numero)
    return(data)
  })
  
  return(requerimentos)
}

#' @title Retrona as proposições da busca
#' @description Recebe um tipo de proposição, o ano e o termo de busca e monta a requisição à API do Senado e 
#' retorna informaçẽos sobre as proposições filtradas
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param term {String} Termos da busca. Use aspas para definir restrição de termos com mais de uma palavra
#' @return Conjunto de ID das proposições filtradas
#' @example requerimentos_ministra_agricultura <- filter_proposicoes_by_term_senado(term = '"Ministra da Agricultura"')
fetch_req_informacao_autores_senado <- function(
  tipo_proposicao = "req", 
  ano = 2019, 
  term = '"Ministra da Agricultura"|"Ministra de Estado da Agricultura"|"Ministro do Meio Ambiente"|"Ministro de Estado do Meio Ambiente"') {
  
  library(tidyverse)
  library(here)
  
  source(here::here("parlametria/crawler/articulacoes/fetcher_authors.R"))
  
  proposicoes <- filter_proposicoes_by_term_senado(tipo_proposicao, ano, term)
  
  autores <- fetch_all_autores_senado(proposicoes)
  
  autores_alt <- autores %>% 
    group_by(id) %>% 
    summarise(num_req_informacao = n_distinct(id_proposicao))
  
  return(autores_alt)
}

#' @title Recupera autores (deputados e senadores) de requerimentos em 2019 que convidaram a Ministra da Agricultura
#' e o Ministro do Meio Ambiente para se apresentar em sessões no Congresso.
#' @description Recupera autores (deputados e senadores) de requerimentos em 2019 que convidaram a Ministra da Agricultura
#' e o Ministro do Meio Ambiente para se apresentar em sessões no Congresso.
#' @return Conjunto de autores dos requerimentos
#' @example requerimentos <- fetch_req_informacao_ambiente_agricultura()
fetch_req_informacao_ambiente_agricultura <- function() {
  library(tidyverse)
  library(here)
  
  autores_camara <- fetch_req_informacao_autores_camara(tipo_proposicao = "RIC",
                                                        ano = 2019,
                                                        terms = c('agricultura', 'meio ambiente')) %>% 
    mutate(casa = "camara")
  
  autores_senado <- fetch_req_informacao_autores_senado(tipo_proposicao = "req", 
                                                        ano = 2019, 
                                                        term = '"Ministra da Agricultura"|"Ministra de Estado da Agricultura"|"Ministro do Meio Ambiente"|"Ministro de Estado do Meio Ambiente"') %>% 
    mutate(casa = "senado")
  
  autores_requerimento <- autores_camara %>% 
    rbind(autores_senado)
  
  return(autores_requerimento)
}


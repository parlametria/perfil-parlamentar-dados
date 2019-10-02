#' @title Retorna os autores de proposições sobre determinados assuntos, ano e tipo de proposição
#' @description Recebe o tipo da proposição (SIGLA), o ano e os termos de busca do filtro e retorna 
#' os autores das proposições encontradas.
#' @param tipo_proposicao Sigla do tipo da proposição
#' @param ano Ano de apresentação das proposições
#' @param terms Termos da buca
#' @return Dataframe dos autores das proposições encontradas.
fetch_req_informacao_autores <- function(tipo_proposicao = "RIC",
                                         ano = 2019,
                                         terms = c('agricultura', 'meio ambiente')) {
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/coautorias/fetcher_authors.R"))
  
  proposicoes <-
    purrr::map_df(terms, ~ filter_proposicoes_by_term(tipo_proposicao, ano, .x))
  
  autores <- fetch_all_autores(proposicoes)
  
  autores_summarised <- autores %>%
    distinct() %>% 
    group_by(id_deputado) %>%
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
filter_proposicoes_by_term <- function(tipo_proposicao, ano, terms) {
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
        ~ filter_proposicoes_by_term_and_page(tipo_proposicao, ano, terms, .x)
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
filter_proposicoes_by_term_and_page <- function(tipo_proposicao, ano, terms, pag) {
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

#' @title Extrai informações sobre o mandato de um senador
#' @description Recebe o id de um senador e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param id_deputado id do deputado
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_mandatos_senado(5322)
extract_mandatos_senado <- function(id_senador) {
  library(fuzzyjoin)
  library(tidyverse)
  source(here::here("crawler/parlamentares/mandatos/utils_mandatos.R"))
  url <-
    paste0("http://legis.senado.leg.br/dadosabertos/senador/",
           id_senador,
           "/mandatos")
  
  mandatos <- tryCatch({
      mandatos <- RCurl::getURL(url) %>%
      xml2::read_xml() %>%
      xml2::xml_find_all(".//Mandato") %>%
      purrr::map_df(function(x) {
        mandato <- tribble(
          ~ id_legislatura,
          ~ data_inicio_mandato,
          ~ data_fim_mandato,
          extract_text_from_node(x, "./PrimeiraLegislaturaDoMandato/NumeroLegislatura"),
          extract_text_from_node(x, "./PrimeiraLegislaturaDoMandato/DataInicio"),
          extract_text_from_node(x, "./PrimeiraLegislaturaDoMandato/DataFim"),
          extract_text_from_node(x, "./SegundaLegislaturaDoMandato/NumeroLegislatura"),
          extract_text_from_node(x, "./SegundaLegislaturaDoMandato/DataInicio"),
          extract_text_from_node(x, "./SegundaLegislaturaDoMandato/DataFim")
        ) %>%
          mutate(
            situacao =
              extract_text_from_node(x, "./DescricaoParticipacao"),
            data_inicio_mandato = as.Date(data_inicio_mandato),
            data_fim_mandato = as.Date(data_fim_mandato)
          )
        
        exercicios <- xml2::xml_find_all(x, ".//Exercicio") %>%
          purrr::map_df(function(y) {
            tribble(
              ~ data_inicio,
              ~ data_fim,
              ~ cod_causa_fim_exercicio,
              ~ desc_causa_fim_exercicio,
              extract_text_from_node(y, "./DataInicio") %>% as.Date(),
              extract_text_from_node(y, "./DataFim") %>% as.Date(),
              extract_text_from_node(y, "./SiglaCausaAfastamento"),
              extract_text_from_node(y, "./DescricaoCausaAfastamento")
            )
          }) 
        
          mandatos <- fuzzyjoin::fuzzy_full_join(
            exercicios,
            mandato,
            by = c("data_inicio" = "data_inicio_mandato",
                 "data_inicio" = "data_fim_mandato"),
            match_fun = list(`>=`, `<=`)
        ) %>% 
          arrange(data_inicio, id_legislatura) %>% 
          mutate(
            data_inicio = 
              if_else(is.na(data_inicio), 
                      data_inicio_mandato %>% as.Date(),
                      data_inicio),
            data_fim = if_else(!is.na(lead(data_fim_mandato)) & is.na(data_fim), data_fim_mandato, data_fim))
      }) 
      
      mandatos <- mandatos %>% 
        dplyr::mutate(
          id_parlamentar = as.integer(id_senador),
          casa = "senado",
          cod_causa_fim_exercicio = 
            if_else(is.na(desc_causa_fim_exercicio), 
                    as.integer(NA), 
                    as.integer(cod_causa_fim_exercicio))
          ) 
      
      mandatos <- mandatos %>%
        dplyr::select(
          id_parlamentar,
          casa,
          id_legislatura,
          data_inicio,
          data_fim,
          situacao,
          cod_causa_fim_exercicio,
          desc_causa_fim_exercicio
        )
    
  }, error = function(e) {
    data <- tribble(
      ~ id_parlamentar,
      ~ casa,
      ~ id_legislatura,
      ~ data_inicio,
      ~ data_fim,
      ~ situacao, 
      ~ cod_causa_fim_exercicio,
      ~ desc_causa_fim_exercicio
    )
    return(data)
  })
  
  return(mandatos)
}

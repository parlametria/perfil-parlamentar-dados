#' @title Extrai informações sobre o mandato de um senador
#' @description Recebe o id de um senador e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param id_deputado id do deputado
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_mandatos_senado(5322)
extract_mandatos_senado <- function(id_senador) {
  source(here::here("crawler/parlamentares/mandatos/utils_mandatos.R"))
  url <-
    paste0("http://legis.senado.leg.br/dadosabertos/senador/",
           id_senador,
           "/mandatos")
  
  mandatos <- tryCatch({
    data <-
      RCurl::getURL(url) %>%
      xml2::read_xml() %>%
      xml2::xml_find_all(".//Mandato") %>%
      
      purrr::map_df(function(x) {
        mandato <- tribble(
          ~ id_legislatura,
          ~ data_inicio,
          ~ data_fim,
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
            cod_causa_fim_exercicio =
              extract_text_from_node(x, "./Exercicios/Exercicio/CodigoExercicio"),
            desc_causa_fim_exercicio =
              extract_text_from_node(x, "./Exercicios/Exercicio/DescricaoCausaAfastamento")
          )
      })
    
    data <- data %>%
      dplyr::mutate(
        id_parlamentar = as.integer(id_senador),
        casa = "senado",
        id_legislatura = as.integer(id_legislatura),
        data_inicio = as.Date(data_inicio, "%Y-%m-%d"),
        data_fim = as.Date(data_fim, "%Y-%m-%d"),
        cod_causa_fim_exercicio = 
          if_else(is.na(desc_causa_fim_exercicio), 
                  as.integer(NA), 
                  as.integer(cod_causa_fim_exercicio))) %>%
      dplyr::select(
        id_parlamentar,
        casa,
        id_legislatura,
        data_inicio,
        data_fim,
        situacao,
        cod_causa_fim_exercicio,
        desc_causa_fim_exercicio
      ) %>% 
      arrange(id_legislatura)
    
    return(data)
    
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
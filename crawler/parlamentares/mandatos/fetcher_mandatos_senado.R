#' @title Extrai a legislatura com base em um intervalo de tempo
#' @description A partir de um dataframe de legislaturas e um intervalo de datas, 
#' retorna a legislatura correspondente.
#' @param legislaturas Dataframe de legislaturas
#' @param data_inicio Data de inicio
#' @param data_fim Data de fim
#' @return Id da legislatura correspondente.
find_legislatura <- function(legislaturas, data_inicio, data_fim) {
  leg <- 
    legislaturas %>% 
    filter(data_inicio_leg <= data_inicio & 
             (data_fim_leg >= data_fim | is.na(data_fim))) %>% 
    pull(id_legislatura)
  return(leg)
}

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
           "/historico")
  
  mandatos <- tryCatch({
    xml <-
      RCurl::getURL(url) %>%
      xml2::read_xml() %>%
      xml2::xml_find_all(".//MandatoAtual") 
    
    legislaturas <- tribble(
      ~ id_legislatura,
      ~ data_inicio_leg,
      ~ data_fim_leg,
      extract_text_from_node(xml, "./PrimeiraLegislaturaDoMandato/NumeroLegislatura"),
      extract_text_from_node(xml, "./PrimeiraLegislaturaDoMandato/DataInicio") %>% as.Date(),
      extract_text_from_node(xml, "./PrimeiraLegislaturaDoMandato/DataFim") %>% as.Date(),
      extract_text_from_node(xml, "./SegundaLegislaturaDoMandato/NumeroLegislatura"),
      extract_text_from_node(xml, "./SegundaLegislaturaDoMandato/DataInicio") %>% as.Date(),
      extract_text_from_node(xml, "./SegundaLegislaturaDoMandato/DataFim") %>% as.Date()) %>% 
      mutate(
      situacao = extract_text_from_node(xml, "./DescricaoParticipacao")
      )
    
    mandatos <- xml %>%
      xml2::xml_find_all(".//Exercicio") %>%
      purrr::map_df(function(x) {
        tribble(
          ~ data_inicio,
          ~ data_fim,
          ~ cod_causa_fim_exercicio,
          ~ desc_causa_fim_exercicio,
          extract_text_from_node(x, "./DataInicio") %>% as.Date(),
          extract_text_from_node(x, "./DataFim") %>% as.Date(),
          extract_text_from_node(x, "./SiglaCausaAfastamento"),
          extract_text_from_node(x, "./DescricaoCausaAfastamento")
        )
      }) 
    
    mandatos <- mandatos %>%
      fuzzyjoin::fuzzy_full_join(
        legislaturas,
        by = c("data_inicio" = "data_inicio_leg",
               "data_inicio" = "data_fim_leg"),
        match_fun = list(`>=`, `<=`)
      ) %>%
      arrange(data_inicio, id_legislatura) %>% 
      mutate(
        data_fim = 
          if_else(is.na(data_fim) & 
                    !is.na(lead(data_inicio_leg)), 
                  lead(data_inicio_leg) - 1, 
                  data_fim), 
        data_inicio = 
          if_else(is.na(data_inicio), 
                  data_inicio_leg,
                  data_inicio)) %>% 
      filter(data_inicio <= data_fim_leg) %>% 
      select(-data_inicio_leg, -data_fim_leg)
    
    mandatos <- mandatos %>% 
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

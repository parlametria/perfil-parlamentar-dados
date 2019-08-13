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
      mandatos <- RCurl::getURL(url) %>%
      xml2::read_xml() %>%
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
      
      mandatos %>% 
        dplyr::mutate(
          id_parlamentar = as.integer(id_senador),
          casa = "senado",
          cod_causa_fim_exercicio = 
            if_else(is.na(desc_causa_fim_exercicio), 
                    as.integer(NA), 
                    as.integer(cod_causa_fim_exercicio))) %>%
        dplyr::select(
          id_parlamentar,
          casa,
          data_inicio,
          data_fim,
          cod_causa_fim_exercicio,
          desc_causa_fim_exercicio
        )
    
  }, error = function(e) {
    data <- tribble(
      ~ id_parlamentar,
      ~ casa,
      ~ data_inicio,
      ~ data_fim,
      ~ cod_causa_fim_exercicio,
      ~ desc_causa_fim_exercicio
    )
    return(data)
  })
  
  return(mandatos)
}

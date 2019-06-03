#' @title Extrai informações sobre o mandato de um parlamentar
#' @description Recebe o id e a casa de um parlamentar e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param id_parlamentar id do parlamentar
#' @param casa casa do parlamentar
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_mandatos(141428, "camara")
extract_mandatos <- function(id_parlamentar, casa) {
  print(paste0("Baixando informações de mandatos do parlamentar de id ", id_parlamentar, " na casa ", casa, "..."))
  if (tolower(casa) == 'camara') {
    return(extract_mandatos_camara(id_parlamentar))
  } else {
    # TODO: Implementar função de extracao de mandatos de um senador
  }
}

#' @title Extrai informações sobre o mandato de um deputado
#' @description Recebe o id de um deputado e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param id_deputado id do deputado
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_mandatos_camara(141428)
extract_mandatos_camara <- function(id_deputado) {
  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Deputados.asmx/ObterDetalhesDeputado?ideCadastro=", 
                id_deputado, "&numLegislatura=")
  
  mandatos <- tryCatch({
    data <- 
      RCurl::getURL(url) %>% xml2::read_xml() %>% 
      xml2::xml_find_all(".//Deputado") %>% 
      purrr::map_df(function(x) {
        list(
          id_legislatura = 
            xml2::xml_find_first(x, "./numLegislatura") %>%
            xml2::xml_text(),
          data_inicio = 
            xml2::xml_find_first(x,"./periodosExercicio/periodoExercicio/dataInicio") %>%
            xml2::xml_text(),
          data_fim = 
            xml2::xml_find_first(x, "./periodosExercicio/periodoExercicio/dataFim") %>%
            xml2::xml_text(),
          situacao = 
            xml2::xml_find_first(x, "./periodosExercicio/periodoExercicio/situacaoExercicio") %>%
            xml2::xml_text(),
          cod_causa_fim_exercicio = 
            xml2::xml_find_first(x, "./periodosExercicio/periodoExercicio/idCausaFimExercicio") %>%
            xml2::xml_text(),
          desc_causa_fim_exercicio = 
            xml2::xml_find_first(x, "./periodosExercicio/periodoExercicio/descricaoCausaFimExercicio") %>%
            xml2::xml_text()
        )
      })
    
    data <- data %>% 
      dplyr::mutate(id_parlamentar = as.integer(id_deputado),
                    casa = "camara",
                    id_legislatura = as.integer(id_legislatura),
                    data_inicio = as.Date(data_inicio, "%d/%m/%Y"),
                    data_fim = as.Date(data_fim, "%d/%m/%Y"),
                    cod_causa_fim_exercicio = as.integer(cod_causa_fim_exercicio),
                    desc_causa_fim_exercicio = gsub('\n ', NA, desc_causa_fim_exercicio)) %>% 
      dplyr::select(id_parlamentar, casa, id_legislatura, data_inicio, data_fim, situacao, 
                    cod_causa_fim_exercicio, desc_causa_fim_exercicio)
    
  }, error = function(e) {
    data <- tribble(
      ~ id_parlamentar, ~ casa, ~ id_legislatura, ~ data_inicio, ~ data_fim, 
      ~ situacao, ~ cod_causa_fim_exercicio, ~ desc_causa_fim_exercicio)
    return(data)
  })
  
  return(mandatos)
}

#' @title Extrai informações sobre os mandato de todos os parlamentares
#' @description Recebeum dataframe contendo id e casa dos parlamentares e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param df_parlamentares dataframe com informações de id e casa dos parlamentares
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_all_mandatos(readr::read_csv(here::here("crawler/raw_data/parlamentares.csv")))
extract_all_mandatos <- function(df_parlamentares) {
  mandatos <-
    purrr::map2_df(df_parlamentares$id, df_parlamentares$casa, 
                   ~ extract_mandatos(.x, .y)) %>% 
    distinct()
  return(mandatos)
}
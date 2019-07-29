#' @title Recupera e processa dados de uma proposição
#' @description A partir de um id, retorna os dados de uma proposição
#' @param id_proposicao ID da proposição
#' @return Dataframe com os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_senado(id_proposicao)
fetch_proposicoes_senado <- function(id_proposicao) {
  library(tidyverse)
  proposicao <- 
    rcongresso::fetch_proposicao_senado(id_proposicao) %>% 
    select(
      id = codigo_materia,
      data_apresentacao,
      nome = descricao_identificacao_materia,
      ementa = ementa_materia,
      tema = assunto_especifico,
      autor = autor_nome
    ) %>%
    mutate(
      uri_tramitacao = 
        paste0(
          "https://www25.senado.leg.br/web/atividade/materias/-/materia/",
          id_proposicao)
      )
  return(proposicao)
}

#' @title Recupera e processa dados de um conjunto de proposições
#' @description A partir de uma lista de ids, retorna os dados das respectivas proposições
#' @param ids lista de ids de proposições
#' @return Dataframe com os dados de proposições
#' @examples
#' proposicoes <- fetch_all_proposicoes(ids)
fetch_all_proposicoes <- function(ids) {
  proposicoes <-purrr::map_df(ids, ~ fetch_proposicoes_senado(.x))
  return(proposicoes)
}
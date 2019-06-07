#' @title Recupera informações das votações nominais do plenário e das proposições em um intervalo de tempo (anos)
#' @description A partir de um ano de início e um ano de fim, recupera dados de
#' votações nominais de plenário que aconteceram na Câmara dos Deputados e das respectivas proposições.
#' @param ano_inicial Ano inicial do período de votações
#' @param ano_final Ano final do período de votações
#' @return Votações e informações sobre as proposições em um intervalo de tempo (anos)
#' @examples
#' votacoes <- export_votacoes_nominais()
export_votacoes_nominais <-
  function(ano_inicial = 2015,
           ano_final = 2019,
           output = here::here("crawler/raw_data/votacoes_nominais_15_a_19.csv")) {
    library(tidyverse)
    source(here::here("crawler/votacoes/fetcher_votacoes.R"))
    
    
    votacoes <-
      fetch_all_votacoes_por_intervalo(ano_inicial, ano_final)
    
    proposicoes_votadas <-
      purrr::map_df(votacoes$id_proposicao,
                    ~ rcongresso::fetch_proposicao_camara(.x)) %>%
      mutate(
        nome = paste0(siglaTipo, " ", numero, "/", ano),
        data_apresentacao = lubridate::ymd_hm(gsub("T", " ", data_apresentacao)) %>%
          format("%d/%m/%Y"),
        id = as.character(id)
      ) %>%
      select(id, nome, data_apresentacao, ementa)
    
    votacoes_proposicoes <- votacoes %>%
      left_join(proposicoes_votadas, by = c("id_proposicao" = "id")) %>%
      distinct() %>%
      select(
        id_proposicao,
        nome_proposicao = nome,
        data_apresentacao_proposicao = data_apresentacao,
        ementa_proposicao = ementa,
        obj_votacao,
        cod_sessao,
        data_votacao = data,
        hora_votacao = hora
      )
    
    write_csv(votacoes_proposicoes, output)
    
    return(votacoes_proposicoes)
  }
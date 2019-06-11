#' @title Recupera informações de uma proposição
#' @description A partir do id, recupera dados de uma proposição na Câmara dos Deputados,
#' como nome, data_apresentacao, ementa, autor, indexacao, tema e uri_tramitacao
#' @param id_prop ID de uma proposição
#' @return Dataframe contendo informações de uma proposição
#' @examples
#' proposicao <- fetch_info_proposicao(2193540)
fetch_info_proposicao <- function(id_prop) {
  print(paste0("Baixando informações da proposição ", id_prop))
  
  url <-
    paste0(
      "https://www.camara.leg.br/proposicoesWeb/prop_autores?idProposicao=",
      id_prop
    )
  
  autor <- httr::GET(url, httr::accept_json()) %>%
    httr::content('text', encoding = 'utf-8') %>%
    xml2::read_html()  %>%
    rvest::html_nodes('#content') %>%
    rvest::html_nodes('span') %>%
    rvest::html_text()
  
  temas  <- tryCatch({
    url <-
      paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
             id_prop,
             "/temas")
    data <- (RCurl::getURI(url) %>%
               jsonlite::fromJSON())$dados %>%
      as.data.frame() %>%
      select(tema)
    
  }, error = function(e) {
    return(dplyr::tribble(~ tema))
  })
  
  proposicao <- rcongresso::fetch_proposicao_camara(id_prop) %>%
    mutate(
      nome = paste0(siglaTipo, " ", numero, "/", ano),
      data_apresentacao = lubridate::ymd_hm(gsub("T", " ", dataApresentacao)) %>%
        format("%d/%m/%Y"),
      id = as.character(id),
      autor = paste(autor[3:length(autor)], collapse = ', ') ,
      tema = paste(unlist(temas$tema), collapse = ', '),
      uri =
        paste0(
          "https://camara.gov.br/proposicoesWeb/fichadetramitacao?idProposicao=",
          id_prop
        ),
      uri_documentos_importantes =
        paste0(
          "https://www.camara.leg.br/proposicoesWeb/prop_pareceres_substitutivos_votos?idProposicao=",
          id_prop
        )
    ) %>%
    select(
      id,
      nome,
      data_apresentacao,
      ementa,
      autor,
      indexacao = keywords,
      tema,
      uri_tramitacao = uri,
      uri_documentos_importantes
    )
  
  return(proposicao)
}

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
      purrr::map_df(votacoes$id_proposicao %>% unique(),
                    ~ fetch_info_proposicao(.x))
    
    votacoes_proposicoes <- votacoes %>%
      left_join(proposicoes_votadas, by = c("id_proposicao" = "id")) %>%
      distinct() %>%
      select(
        id_proposicao,
        nome_proposicao = nome,
        data_apresentacao_proposicao = data_apresentacao,
        ementa_proposicao = ementa,
        autor,
        indexacao,
        tema,
        uri_tramitacao,
        uri_documentos_importantes,
        obj_votacao,
        cod_sessao,
        data_votacao = data,
        hora_votacao = hora
      )
    
    write_csv(votacoes_proposicoes, output)
    
    return(votacoes_proposicoes)
  }
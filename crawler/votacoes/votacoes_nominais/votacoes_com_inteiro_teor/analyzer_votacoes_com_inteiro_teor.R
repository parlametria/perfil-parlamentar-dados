library(tidyverse)

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
      uri_tramitacao = uri
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
        obj_votacao,
        cod_sessao,
        data_votacao = data,
        hora_votacao = hora
      )
    
    votacoes_nominais <- get_inteiro_teor(votacoes_proposicoes)
    
    write_csv(votacoes_nominais, output)
    
    return(votacoes_nominais)
  }

#' @title Recupera link para o inteiro teor do objeto de votação
#' @description Recupera links para os inteiros teores dos objeto de votação de um dataframe
#' @param df Dataframe com informações de proposições e das votações
#' @return Dataframe contendo mais uma coluna link_documento_votacao
#' @examples
#' votacoes <- get_inteiro_teor(df)
get_inteiro_teor <- function(df) {
  library(tidyverse)
  regex <- jsonlite::fromJSON(here::here("crawler/votacoes/votacoes_nominais/votacoes_com_inteiro_teor/constants.json"))
  
  df <- 
    preprocess_votacoes_nominais(df)
  
  votacoes_nominais <- df %>% 
    rowwise(.) %>%
    mutate(
      link_documento_votacao = fetch_relacionadas(
        id_proposicao,
        data_votacao,
        tipo_documento_votacao,
        numero_documento
      )) %>% 
    arrange(desc(data_votacao))
  
  return(votacoes_nominais)
}

#' @title Preprocessa dados do dataframe de votação
#' @description Filtra as votações importantes, extrai o tipo do documento e o número da emenda a partir do obj_votacao
#' @param df Dataframe com informações de proposições e das votações
#' @return Dataframe contendo mais duas colunas tipo_documento_votacao e numero_documento
#' @examples
#' votacoes <- get_inteiro_teor(df)
preprocess_votacoes_nominais <- function(df) {
  library(tidyverse)
  regex <-
    jsonlite::fromJSON(here::here("crawler/votacoes/votacoes_nominais/constants.json"))
  
  # Remove votações menos relevantes
  df <- df %>%
    filter(!str_detect(
      tolower(obj_votacao),
      regex$tipos_documentos_desnecessarios_regex
    ))
  
  # Mapeia o obj_votacao para o tipo do documento e extrai o numero da emenda/proposicao
  df <- df %>%
    mutate(lower_obj_votacao = tolower(obj_votacao)) %>%
    fuzzyjoin::regex_left_join(regex$regex_tipos_documentos,
                               by = c("lower_obj_votacao" = "regex")) %>%
    select(-regex, -lower_obj_votacao) %>%
    mutate(
      tipo_documento_votacao =
        if_else(
          is.na(tipo_documento_votacao),
          gsub(
            regex$begin_with_number_regex,
            regex$empty_string,
            nome_proposicao
          ),
          tipo_documento_votacao
        ),
      numero_documento =
        gsub(
          regex$numero_artigo_regex,
          regex$empty_string,
          str_remove(tolower(obj_votacao),
                     regex$numero_detaques_regex) %>%
            str_extract(regex$numero_documento_regex)
        ) %>%
        str_extract(regex$only_numbers_regex) %>%
        as.numeric()
    ) %>%
    group_by(id_proposicao, obj_votacao) %>%
    mutate(primeiro_match = first(tipo_documento_votacao)) %>%
    filter(tipo_documento_votacao == primeiro_match) %>%
    select(-primeiro_match) %>%
    distinct()
  
  return(df)
}

#' @title Recupera as proposições relacionadas a uma proposição
#' @description A partir do id da proposição, data da votação, tipo do documento e numero do documento, 
#' recupera as proposições relacionadas a uma proposição
#' @param prop_id Id da proposição
#' @param data_votacao Data da votação
#' @param tipo_documento_votacao Tipo do documento do objeto da votação
#' @param numero_documento Número do documento
#' @return Dataframe contendo mais duas colunas tipo_documento_votacao e numero_documento
#' @examples
#' relacionadas <- fetch_relacionadas(516111, '05/06/2019', 'EMA', 1)
fetch_relacionadas <- function(prop_id, data_votacao, tipo_documento_votacao, numero_documento) {
  tipo_documento_votacao = gsub(' ', '', tipo_documento_votacao)
  
  paste0(
    "Processando dados das relacionadas da proposicao ",
    prop_id,
    " na votação do dia ",
    data_votacao,
    " para o documento ",
    tipo_documento_votacao,
    " com numero de emenda ",
    numero_documento
  ) %>%
    print()
  
  url <-
    paste0(
      'https://dadosabertos.camara.leg.br/api/v2/proposicoes/',
      prop_id,
      '/relacionadas'
    )
  
  data <- (RCurl::getURI(url) %>%
             jsonlite::fromJSON())$dados %>%
    as_tibble()
  
  if (nrow(data) == 0) {
    data <- tribble(~ siglaTipo, ~ id, tipo_documento_votacao, prop_id)
  }
  
  data <- data %>%
    select(siglaTipo, id) %>% 
    rbind(tribble(~ siglaTipo, ~id, tipo_documento_votacao, prop_id)) %>% 
    filter(siglaTipo == tipo_documento_votacao) %>% 
    select(id)
  
  rels <-
    purrr::map_df(data$id, function(x) {
      data <- tryCatch({
        rcongresso::fetch_proposicao_camara(x)
      }, error = function(e) {
        return(tribble())
      })
    })
  
  res <- rels %>%
    filter(siglaTipo == tipo_documento_votacao & numero == numero_documento) %>%
    arrange(dataApresentacao) %>%
    tail(1)
  
  if (nrow(res) == 0) {
    res <- rels %>%
      filter(siglaTipo == tipo_documento_votacao & dataApresentacao <= lubridate::ymd(data_votacao)) %>%
      arrange(dataApresentacao) %>%
      tail(1)
  }
  
  if (nrow(res) > 0) {
    return(res$urlInteiroTeor)
  }
  
  return('-')
}
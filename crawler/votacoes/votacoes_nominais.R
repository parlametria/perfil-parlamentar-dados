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

fetch_sigla_tipo_documento <- function(tipo_documento_votacao) {
  url <- 'https://dadosabertos.camara.leg.br/api/v2/referencias/proposicoes/siglaTipo'
  
  data <- (RCurl::getURI(url) %>% 
    jsonlite::fromJSON())$dados %>% 
    as_tibble()
  
}

fetch_relacionadas <- function(prop_id, data_votacao, tipo_documento_votacao) {
  
  sigla_tipo_documento <- fetch_sigla_tipo_documento(tipo_documento_votacao)
  
  
  relacionadas <- tryCatch({
    url <- paste0('https://dadosabertos.camara.leg.br/api/v2/proposicoes/', prop_id, '/relacionadas')
    
    data <- RCurl::getURI(url) %>% 
      jsonlite::fromJSON() %>% 
      as_tibble()
    
  }, error = function(e){
    
  })
  
  
}

process_votacoes_nominais <- function(input_datapath = here::here("crawler/raw_data/votacoes_nominais_15_a_19.csv")) {
  library(tidyverse)
  
  df <- read_csv(input_datapath)
  
  df <- df %>% 
    filter(!str_detect(tolower(obj_votacao), 
                         "req(uerimento|)|urgência|parecer|prorrogação|artigo por artigo|dispensa|efeito suspensivo|diretrizes|dvs|solicita|recurso|consulta|contra|convocação"))
  
  df <- df %>% mutate(tipo_documento_votacao = 
                  case_when(
                            str_detect(tolower(obj_votacao), 'dtq|destaque') ~ 'DTQ',
                            str_detect(tolower(obj_votacao), 'redação final') ~ 'RDF',
                            str_detect(tolower(obj_votacao), '(substitutivo|emenda) .*do senado federal') ~ 'EMS',
                            str_detect(tolower(obj_votacao), 'proposta de emenda à constituição|pec') ~ 'PEC',
                            str_detect(tolower(obj_votacao), 'projeto de lei complementar') ~ 'PLP',
                            str_detect(tolower(obj_votacao), 'projeto de lei de conversão.*') ~ 'PLV',
                            str_detect(tolower(obj_votacao), 'projeto de decreto legislativo') ~ 'PDC',
                            str_detect(tolower(obj_votacao), 'projeto de resolução') ~ 'PRC',
                            str_detect(tolower(obj_votacao), 'projeto de lei') ~ 'PL',
                            str_detect(tolower(obj_votacao), 'medida provisória') ~ 'MPV',
                            str_detect(tolower(obj_votacao), '(substitutivo|emenda) .*do senado federal') ~ 'EMS',
                            str_detect(tolower(obj_votacao), 'substitutivo(.*comissão|.* da C.*)') ~ 'SBT-A',
                            str_detect(tolower(obj_votacao), 'substitutivo(.*relator|)') ~ 'SBT',
                            str_detect(tolower(obj_votacao), 'subemenda substitutiva .* de plenário') ~ 'SSP',
                            str_detect(tolower(obj_votacao), 'subemenda substitutiva da C.*') ~ 'SBE-A',
                            str_detect(tolower(obj_votacao), 'emenda(s|) aglutinativa(s|)') ~ 'EMA',
                            str_detect(tolower(obj_votacao), 'emenda(s|) de plenário') ~ 'EMP',
                            str_detect(tolower(obj_votacao), 'emenda(s|) de redação') ~ 'ERD',
                            str_detect(tolower(obj_votacao), 'emenda substitutiva global de plenário') ~ 'ESP',
                            str_detect(tolower(obj_votacao), 'emenda substitutiva global') ~ 'EAG',
                            str_detect(tolower(obj_votacao), 'emenda(s|)') ~ 'EMD',
                            TRUE ~ 'Outros')) 
  
}
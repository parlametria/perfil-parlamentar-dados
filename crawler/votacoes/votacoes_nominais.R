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
        data_apresentacao = lubridate::ymd_hm(gsub("T", " ", dataApresentacao)) %>%
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

fetch_relacionadas <- function(prop_id, data_votacao, tipo_documento_votacao, numero_emenda) {
    tipo_documento_votacao = gsub(' ', '', tipo_documento_votacao)
    
    paste0(
      "Processando dados das relacionadas da proposicao ",
      prop_id,
      " na votação do dia ",
      data_votacao,
      " para o documento ",
      tipo_documento_votacao,
      " com numero de emenda ",
      numero_emenda
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
      as_tibble() %>%
      select(siglaTipo, id) %>% 
      rbind(tribble(~ siglaTipo, ~id, tipo_documento_votacao, prop_id)) %>% 
      filter(siglaTipo == tipo_documento_votacao) %>% 
      select(id)
    
    if (nrow(data) == 0) {
      data <- tribble( ~ id, prop_id)
    }
    
    rels <-
      purrr::map_df(data$id, function(x) {
        data <- tryCatch({
          rcongresso::fetch_proposicao_camara(x)
        }, error = function(e) {
          return(tribble())
        })
      })
    
    res <- rels %>%
        filter(siglaTipo == tipo_documento_votacao & numero == numero_emenda) %>%
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

process_votacoes_nominais <-
  function(input_datapath = here::here("crawler/raw_data/votacoes_nominais_15_a_19.csv")) {
    library(tidyverse)
    
    df <- read_csv(input_datapath)
    
    df <- df %>%
      filter(
        !str_detect(
          tolower(obj_votacao),
          "req(uerimento|)|urgência|parecer|prorrogação|artigo por artigo|dispensa|efeito suspensivo|diretrizes|dvs|solicita|recurso|consulta|contra|convocação"
        )
      )
    
    df <- map_obj_votacao_to_sigla_tipo(df)
    
    teste <- df %>%
      slice(1:300) %>% 
      rowwise(.) %>%
      mutate(
        link_documento_votacao = fetch_relacionadas(
          id_proposicao,
          data_votacao,
          tipo_documento_votacao,
          numero_emenda
        ))
      # ) %>% 
      # filter(link_documento_votacao != '-') %>% 
      # arrange(desc(data_votacao))
    
    
    
    # PSordenar data de votação decrescentemente
    
  }



map_obj_votacao_to_sigla_tipo <- function(df) {
  
  return(df %>% mutate(
    tipo_documento_votacao =
      case_when(
        str_detect(tolower(obj_votacao), 'redação final') ~ 'RDF',
        
        str_detect(tolower(obj_votacao), 'projeto de lei complementar') ~ 'PLP',
        str_detect(tolower(obj_votacao), 'projeto de lei de conversão.*|plv') ~ 'PLV',
        str_detect(tolower(obj_votacao), 'projeto de decreto legislativo|pdc') ~ 'PDC',
        str_detect(tolower(obj_votacao), 'projeto de resolução|prc') ~ 'PRC',
        
        str_detect(tolower(obj_votacao), 'medida provisória|mpv') ~ 'MPV',
        str_detect(
          tolower(obj_votacao),
          '(substitutivo|emenda(s|)) .*do senado federal'
        ) ~ 'EMS',
        str_detect(tolower(obj_votacao), 'substitutivo (.*comissão|da c.*)') ~ 'SBT-A',
        
        str_detect(
          tolower(obj_votacao),
          'subemenda subst(itutiva|.).* relator.*'
        ) ~ 'SBR',
        str_detect(
          tolower(obj_votacao),
          'subemenda substitutiva(.* de plenário|)'
        ) ~ 'SSP',
        str_detect(tolower(obj_votacao), 'projeto de lei|pl |lei') ~ 'PL',
        str_detect(tolower(obj_votacao), 'subemenda substitutiva da C.*') ~ 'SBE-A',
        str_detect(tolower(obj_votacao), 'emenda(s|) aglutinativa(s|)') ~ 'EMA',
        str_detect(tolower(obj_votacao), 'emenda(s|) de redação') ~ 'ERD',
        str_detect(tolower(obj_votacao), 'substitutivo|subst\\.') ~ 'SBT',
        str_detect(tolower(obj_votacao), 'proposta de emenda à constituição|pec ') ~ 'PEC',
        str_detect(tolower(obj_votacao), 'emenda(s|).*(substitutiva|) (de plenário|)') ~ 'EMP',
        str_detect(
          tolower(obj_votacao),
          'emenda substitutiva global de plenário'
        ) ~ 'EMP',
        str_detect(tolower(obj_votacao), 'emenda substitutiva global') ~ 'EMP',
        str_detect(tolower(obj_votacao), 'emenda(s|)') ~ 'EMD',
        str_detect(tolower(obj_votacao), 'art(igo|.)') ~ gsub(' \\d.*', '', nome_proposicao),
        
        TRUE ~ 'Outros'
      ),
    
    numero_emenda = 
      gsub("?/.*|§.*|.*º", '', 
           str_remove(tolower(obj_votacao), 
                      'dtq(.|) [\\d]+.*(:|-)') %>% 
             str_extract('(nº .*)|.*')) %>% 
      str_extract("[\\d]+") %>% 
      as.numeric()
  ))
}

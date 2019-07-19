#!/usr/bin/env Rscript
source(here::here("crawler/votacoes/utils/constants.R"))
source(here::here("crawler/parlamentares/deputados/fetcher_deputado.R"))

# Bibliotecas
library(tidyverse)
library(rcongresso)

#' @title Enumera tipos de objetivos de votações
#' @description Recebe um dataframe com coluna obj_votacao e enumera o valor para um número
#' @param df Dataframe com a coluna obj_votacao
#' @return Dataframe com coluna obj_votacao_enum enumerada
#' @examples
#' enumera_tipos_objetivos_votacao(df)
enumera_tipos_objetivos_votacao <- function(df) {
  df %>%
    mutate(obj_votacao_enum = case_when(
      str_detect(obj_votacao, .PDL) ~ 1,
      str_detect(obj_votacao, .PEC_SEGUNDO_TURNO) ~ 1,
      str_detect(obj_votacao, .SUBEMENDA_SUBST_GLOBAL) ~ 4,
      str_detect(obj_votacao, .DESTAQUE) ~ 5,
      str_detect(obj_votacao, .EMENDA_SUBTS_GLOBAL) ~ 3,
      str_detect(obj_votacao, .SUBST_COM_ESPECIAL) ~ 2,
      str_detect(obj_votacao, .SUBST_RELATOR) ~ 2,
      str_detect(obj_votacao, .PARECER_CM_ATEND_PRESSU_CONST) ~ 4,
      str_detect(obj_votacao, .SUBEMENDA_SUBST_CDEIC) ~ 4,
      str_detect(obj_votacao, .VOT_ADMISS_GLOBO) ~ 4,
      str_detect(obj_votacao, .SUBST_CFT) ~ 2,
      str_detect(obj_votacao, .SUBEMENDA_SUBST) ~ 4,
      str_detect(obj_votacao, .SUBST_SF) ~ 2,
      str_detect(obj_votacao, .PLC) ~ 1,
      str_detect(obj_votacao, .EMENDA_AGLUT_4) ~ 3,
      TRUE ~ 5))
}

#' @title Importa e processa dados de votações na Câmara dos Deputados
#' @description Recebe informações da proposição e da votação específica para obtenção dos votos
#' @param id_proposicao Id da prposição para obtenção dos votos
#' @param id_votacao Id da votação no contexto interno do Voz Ativa
#' @param resumo_votacao Resumo da Votação
#' @param objeto_votacao Objeto da Votação
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- fetch_votos_camara(2165578, 8334)
fetch_votos_camara <- function(id_proposicao, numero_projeto_lei, id_votacao, resumo_votacao, objeto_votacao) {
  library(xml2)
  
  proposicoes <- tibble(
    siglaTipo = strsplit(numero_projeto_lei, " ")[[1]][1],
    numero = strsplit(strsplit(numero_projeto_lei, "/")[[1]][1], " ")[[1]][2],
    ano = strsplit(numero_projeto_lei, "/")[[1]][2]
  )

  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=",
                proposicoes$siglaTipo, "&numero=", proposicoes$numero, "&ano=", proposicoes$ano)
  
  print(paste0("Baixando votação da ", proposicoes$siglaTipo, " ", proposicoes$numero, "/", proposicoes$ano))
  
  tryCatch({
    xml <- 
      RCurl::getURL(url) %>%
      read_xml()
    
    votacao <- xml_find_all(xml, ".//Votacao") %>%
      map_df(function(x) {
        list(
          obj_votacao = xml_attr(x, "ObjVotacao"),
          resumo = xml_attr(x, "Resumo"),
          cod_sessao = xml_attr(x, "codSessao"),
          data = as.Date(xml_attr(x, "Data"), "%d/%m/%Y"),
          hora = xml_attr(x, 'Hora')
        )
      })
    
    ## Escolhe votação específica
    if(nrow(votacao) > 1) {
      if(is.na(resumo_votacao)) {
        votacao <- votacao %>%
          mutate(obj_votacao = trimws(obj_votacao, which = "both")) %>%  
          filter(obj_votacao == trimws(objeto_votacao, "both"))  
      } else {
        votacao <- votacao %>%
          mutate(resumo = trimws(resumo, which = "both")) %>%  
          filter(resumo == trimws(resumo_votacao, "both"))  
      }
    }
    
    ## Captura os dados dos votos
    votos <- xml2::xml_find_all(xml, paste0(".//Votacao[@ObjVotacao = '",
                                            votacao$obj_votacao, "']",
                                            "//votos//Deputado")) %>%
      map_df(function(x) {
        list(
          id_deputado = xml_attr(x, "ideCadastro"),
          voto = xml_attr(x, "Voto") %>%
            gsub(" ", "", .),
          partido = xml_attr(x, "Partido"))
      }) %>%
      mutate(obj_votacao = votacao$obj_votacao,
             resumo = votacao$resumo,
             hora = votacao$hora,
             cod_sessao = votacao$cod_sessao,
             id_votacao = id_votacao,
             id_proposicao = id_proposicao,
             id_deputado = as.integer(id_deputado)) %>%
      select(obj_votacao,
             resumo,
             id_votacao,
             id_proposicao,
             hora,
             cod_sessao,
             id_deputado,
             partido,
             voto)
    return(votos)
  }, error = function(e) {
    return(tribble(~obj_votacao,
                   ~resumo,
                   ~id_votacao,
                   ~id_proposicao,
                   ~hora,
                   ~cod_sessao,
                   ~id_deputado,
                   ~partido,
                   ~voto))
  })
  
}

#' @title Processa votações e informações dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes Dataframe com informações das votações para captura dos votos
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados
#' @examples
#' processa_votos_camara(votacoes)
processa_votos_camara <- function(votacoes) {
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  proposicao_votacao <- votacoes %>% 
    dplyr::filter(!is.na(id_sessao)) %>% 
    dplyr::select(numero_proj_lei, id_proposicao, id_sessao, resumo, objeto_votacao)

  votos <- purrr::pmap_dfr(list(proposicao_votacao$id_proposicao, 
                                proposicao_votacao$numero_proj_lei,
                                proposicao_votacao$id_sessao, 
                                proposicao_votacao$resumo,
                                proposicao_votacao$objeto_votacao), 
                    ~ fetch_votos_camara(..1, ..2, ..3, ..4, ..5))

  parlamentares_filepath = here::here("crawler/raw_data/parlamentares.csv")
  
  if(file.exists(parlamentares_filepath)) {
    parlamentares <- readr::read_csv(parlamentares_filepath)
    
  } else {
    # IDS das últimas duas legislaturas
    legislaturas_list <- c(55,56)
    parlamentares <- purrr::map_df(legislaturas_list, ~ fetch_deputados(.x))
  }

  votos_alt <- votos %>% 
    dplyr::mutate(casa = "camara") %>%
    dplyr::select(id_proposicao, id_votacao, id_parlamentar = id_deputado, casa, partido, voto) %>% 
    enumera_voto() %>% 
    dplyr::distinct()

  return(votos_alt)
}

#' @title Processa votações dos parlamentares
#' @description O processamento consiste em mapear as votações dos parlamentares (caso tenha votado) e tratar os casos quando ele não votou
#' @param url Link para o csv com as posições do questionário do Voz Ativa
#' @return Dataframe contendo o id da votação, o id do parlamentar, a casa e o voto dos parlamentares
#' @examples
#' processa_votos(url)
processa_votos <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTMcbeHRm_dqX-i2gNVaCiHMFg6yoIjNl9cHj0VBIlQ5eMX3hoHB8cM8FGOukjfNajWDtfvfhqxjji7/pub?gid=0&single=true&output=csv") {
  votacoes_lista <- read_csv(url, col_types = cols(id_proposicao = "c"))
    # filter(status_proposicao == "Ativa") %>% 
    # filter(id_sessao != 99999) # remove votacao da PL 6299/2002 (nao possui votacoes em plenário)
  
  votacoes_camara <- votacoes_lista %>% 
    dplyr::filter(tolower(iconv(casa, 
                        from = "UTF-8", 
                        to = "ASCII//TRANSLIT")) == "camara")
  
  votacoes_senado <- votacoes_lista %>% 
    dplyr::filter(casa == "senado")
  
  votacoes <- processa_votos_camara(votacoes_camara) %>% 
    select(id_proposicao, id_votacao, id_parlamentar, casa, voto)
  
  return(votacoes)
}

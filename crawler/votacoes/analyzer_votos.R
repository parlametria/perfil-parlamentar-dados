#!/usr/bin/env Rscript
source(here::here("crawler/votacoes/utils/constants.R"))
source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))

# Bibliotecas
library(tidyverse)
library(rcongresso)

#' @title Enumera votações
#' @description Recebe um dataframe com coluna voto e enumera o valor para um número
#' @param df Dataframe com a coluna voto
#' @return Dataframe com coluna voto enumerada
#' @examples
#' enumera_votacoes(df)
enumera_votacoes <- function(df) {
  df %>%
    mutate(voto = case_when(str_detect(voto, "Não") ~ -1,
                            str_detect(voto, "Sim") ~ 1,
                            str_detect(voto, "Obstrução") ~ 2,
                            str_detect(voto, "Abstenção") ~ 3,
                            str_detect(voto, "Art. 17") ~ 4,
                            TRUE ~ 0))
}

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

#' @title Importa dados de todos os deputados
#' @description Importa os dados de todos os deputados federais 
#' @return Dataframe contendo informações dos deputados
#' @examples
#' deputados <- get_deputados()
get_deputados <- function(legislaturas_list) {
  deputados <- tryCatch({
    readr::read_csv(here::here("crawler/raw_data/deputados.csv"))
  }, error = function(e) {
    fetch_deputados(legislaturas_list)
  })
  return(deputados)
}

#' @title Importa e processa dados de votações
#' @description Recebe um dataframe com os dados das votações das proposições
#' @param df Dataframe com os dados das votações
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- fetch_votos(2165578, 8334)
fetch_votos <- function(id_proposicao, id_votacao) {
  library(xml2)
  proposicoes <- rcongresso::fetch_proposicao_camara(id_proposicao) %>%
    select(siglaTipo, numero, ano)
  
  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=",
                proposicoes$siglaTipo, "&numero=", proposicoes$numero, "&ano=", proposicoes$ano)

  xml <- RCurl::getURL(url) %>%
    read_xml()

  votacao <- xml_find_all(xml, .QUERY) %>%
    map_df(function(x) {
      list(
        obj_votacao = xml_attr(x, "ObjVotacao"),
        cod_sessao = xml_attr(x, "codSessao"),
        data = as.Date(xml_attr(x, "Data"), "%d/%m/%Y")
      )
    })

  if(nrow(votacao) > 1) {
    votacao <- votacao %>%
     enumera_tipos_objetivos_votacao() %>%
      mutate(minimo = min(obj_votacao_enum)) %>%
               filter(minimo == obj_votacao_enum) %>%
      select(-obj_votacao_enum)
  }

  votos <- xml2::xml_find_all(xml, paste0(".//Votacao[@ObjVotacao = '",
                                          votacao$obj_votacao, "']",
                                          "//votos//Deputado")) %>%
    map_df(function(x) {
      list(
        id_deputado = xml_attr(x, "ideCadastro"),
        voto = xml_attr(x, "Voto") %>%
          gsub(" ", "", .))
      }) %>%
    mutate(obj_votacao = votacao$obj_votacao,
           data_hora = votacao$data,
           id_votacao = id_votacao,
           id_deputado = as.integer(id_deputado)) %>%
    select(id_votacao,
           id_deputado,
           voto)

  return(votos)
}

#' @title Processa votações e informações dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes_datapath Datapath do csv com os dados das votações
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados
#' @examples
#' processa_votos("../raw_data/tabela_votacoes.csv")
processa_votos <- function(votacoes_datapath) {
  proposicao_votacao <- read_csv(votacoes_datapath, col_types = "cdcccc") %>% 
    filter(!is.na(id_votacao)) %>% 
    select(id_proposicao, id_votacao)
  
  votos <- map2_df(proposicao_votacao$id_proposicao, proposicao_votacao$id_votacao, ~ fetch_votos(.x, .y))
  
  # IDS das últimas três legislaturas
  legislaturas_list <- c(55,56)
  
  deputados <- get_deputados(legislaturas_list)
  
  print("Cruzando informações de votos com deputados...")
  votos <- votos %>% 
    inner_join(deputados, by = c("id_deputado" = "id")) %>% 
    select(id_votacao, cpf, voto) %>% 
   enumera_votacoes() %>% 
    distinct()

  return(votos)
}

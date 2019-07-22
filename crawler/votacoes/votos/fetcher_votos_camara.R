#' @title Importa e processa dados de votações na Câmara dos Deputados
#' @description Recebe informações da proposição e da votação específica para obtenção dos votos
#' @param id_proposicao Id da prposição para obtenção dos votos
#' @param id_votacao Id da votação no contexto interno do Voz Ativa
#' @param resumo_votacao Resumo da Votação
#' @param objeto_votacao Objeto da Votação
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- fetch_votos_por_votacao_camara(2165578, 8334)
fetch_votos_por_votacao_camara <- function(id_proposicao, numero_projeto_lei, id_votacao, resumo_votacao, objeto_votacao) {
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

#' @title Recupera votos de um xml de votações a partir do código da sessão e da hora
#' @description Votos dos deputados a partir do código da sessão e da hora
#' @param cod_sessao Código da sessão da votação
#' @param hora Hora da sessão da votação
#' @param xml xml com votações
#' @return Votos dos parlamentares na votação específica
#' @examples
#' votos <- fetch_votos_por_sessao_camara("16821", "19:57", xml)
fetch_votos_por_sessao_camara <- function(cod_sessao, hora, xml) {
  library(tidyverse)
  library(xml2)
  
  votos <- xml_find_all(xml, paste0(".//Votacao[@codSessao = '",
                                    cod_sessao,"' and @Hora = '", hora,"']",
                                    "//votos//Deputado")) %>%
    map_df(function(x) {
      list(
        id_deputado = xml_attr(x, "ideCadastro"),
        voto = xml_attr(x, "Voto") %>%
          gsub(" ", "", .),
        partido = xml_attr(x, "Partido"))
    }) %>%
    select(id_deputado,
           voto,
           partido)
}

#' @title Recupera informações de votos de todas as votações de uma determinada proposição para um determinado ano
#' @description A partir do id da proposição e do ano recupera votos que aconteceram na Câmara dos Deputados
#' @param id_proposicao ID da proposição
#' @param ano Ano para o período de votações
#' @return Votos dos parlametares para a proposição (inclui várias votações)
#' @examples
#' votos <- fetch_votos_por_ano_camara(2190355, 2019)
fetch_votos_por_ano_camara <- function(id_proposicao, ano = 2019) {
  library(tidyverse)
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  if (is.na(id_proposicao)) {
    data <- tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  }
  
  xml <- fetch_xml_api_votacao_camara(id_proposicao)
  
  votacoes_filtradas <- fetch_votacoes_por_ano_camara(id_proposicao, ano, xml) %>% 
    select(obj_votacao, data, cod_sessao, hora, id_votacao)
  
  votos_raw <- tibble(cod_sessao = votacoes_filtradas$cod_sessao,
                      hora = votacoes_filtradas$hora
  ) %>%
    mutate(dados = map2(
      cod_sessao,
      hora,
      fetch_votos_por_sessao_camara,
      xml
    )) %>% 
    unnest(dados)
  
  votos <- votos_raw %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    enumera_voto() %>% 
    mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>% 
    select(id_votacao, id_deputado, voto, partido) %>% 
    distinct()
  
  return(votos)
}
#' @title Lista de proposições votadas em um determinado ano
#' @description Lista as proposições votadas em plenário para um determinado ano
#' @param ano Ano de ocorrência das votações
#' @return Dataframe contendo id da proposição, nome e data da votação
#' @examples
#' proposicoes_votadas_em_2019 <- fetch_votacoes_ano(2019)
fetch_votacoes_ano <- function(ano = 2019) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  library(jsonlite)
  
  url_votacoes <- "https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=%s&tipo="
  
  url <- url_votacoes %>% 
    sprintf(ano)
  
  proposicoes <- tryCatch({
    xml <- getURL(url) %>% read_xml()
    
    data <- xml_find_all(xml, ".//proposicao") %>%
      map_df(function(x) {
        list(
          id = xml_find_first(x, ".//codProposicao") %>% 
            xml_text(),
          nome_proposicao = xml_find_first(x, ".//nomeProposicao") %>% 
            xml_text(),
          data_votacao = xml_find_first(x, ".//dataVotacao") %>% 
            xml_text()
        )
      }) %>%
      select(id, nome_proposicao, data_votacao)# %>%
      #distinct()
  
  }, error = function(e) {
    message(e)
    data <- tribble(
      ~ id, ~ nome_proposicao, ~ data_votacao)
    return(data)
  })
  
  return(proposicoes)
}

#' @title Recupera xml com votações de uma proposição específica
#' @description A partir do id da prosição recupera o xml com as votações em plenário da proposição
#' @param id_proposicao ID da proposição
#' @return XML com as votações da proposição
#' @examples
#' votacoes_mpv8712019 <- fetch_xml_api_votacao(2190355)
fetch_xml_api_votacao <- function(id_proposicao) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  proposicao <- get_sigla_by_id(id_proposicao) %>%
    select(siglaTipo, numero, ano)
  
  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=",
                proposicao$siglaTipo, "&numero=", proposicao$numero, "&ano=", proposicao$ano)
  
  print(paste0("Baixando votação da ", proposicao$siglaTipo, " ", proposicao$numero, "/", proposicao$ano))
  
  xml <- getURL(url) %>%
    read_xml()
  
  return(xml)
}

#' @title Recupera informações de votações a partir de um xml
#' @description A partir do xml das votações recupera dados de todas as votações disponíveis
#' @param id_proposicao ID da proposição
#' @param xml xml com votações
#' @return Info sobre as votações
#' @examples
#' votacoes_mpv8712019 <- fetch_votacoes_por_proposicao(2190355, xml)
fetch_votacoes_por_proposicao <- function(id_proposicao, xml) {
  library(tidyverse)
  library(xml2)
  
  tryCatch({
    votacoes <- xml_find_all(xml, ".//Votacao") %>%
      map_df(function(x) {
        list(
          obj_votacao = xml_attr(x, "ObjVotacao"),
          resumo = xml_attr(x, "Resumo"),
          cod_sessao = xml_attr(x, "codSessao"),
          hora = xml_attr(x, "Hora"),
          data = as.Date(xml_attr(x, "Data"), "%d/%m/%Y")
        )
      })
  }, error = function(e) {
    data <- tribble(~ obj_votacao, ~ resumo, ~ cod_sessao, ~ hora, ~ data)
    return(data)
  })

  return(votacoes)
}

#' @title Recupera votos de um xml de votações a partir do código da sessão e da hora
#' @description Votos dos deputados a partir do código da sessão e da hora
#' @param cod_sessao Código da sessão da votação
#' @param hora Hora da sessão da votação
#' @param xml xml com votações
#' @return Votos dos parlamentares na votação específica
#' @examples
#' votos <- fetch_votos_por_sessao("16821", "19:57", xml)
fetch_votos_por_sessao <- function(cod_sessao, hora, xml) {
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

#' @title Recupera informações das votações de uma determinada proposição para um determinado ano
#' @description A partir do id da proposição e do ano recupera dados de votações que aconteceram na Câmara dos Deputados
#' @param id_proposicao ID da proposição
#' @param ano Ano para o período de votações
#' @return Votações da proposição em um ano
#' @examples
#' votacoes <- fetch_votacoes_por_ano(2190355, 2019)
fetch_votacoes_por_ano <- function(id_proposicao, ano = 2019, xml = NULL) {
  library(tidyverse)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  votacoes <- tryCatch({
    if (is.null(xml)) {
      xml <- fetch_xml_api_votacao(id_proposicao)
    }
    
    votacoes <- fetch_votacoes_por_proposicao(id_proposicao, xml)
    
    votacoes <- votacoes %>% 
      mutate(ano_votacao = format(data, "%Y")) %>% 
      filter(ano_votacao == ano) %>% 
      mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":")),
             id_proposicao = id_proposicao) %>% 
      select(id_proposicao, obj_votacao, data, cod_sessao, hora, id_votacao)
    
  }, error = function(e){
    return(
      tribble(~id_proposicao, ~ obj_votacao, ~ data, ~ cod_sessao, ~ hora, ~ id_votacao))
  })
  
  return(votacoes)
}

#' @title Recupera informações de votos de todas as votações de uma determinada proposição para um determinado ano
#' @description A partir do id da proposição e do ano recupera votos que aconteceram na Câmara dos Deputados
#' @param id_proposicao ID da proposição
#' @param ano Ano para o período de votações
#' @return Votos dos parlametares para a proposição (inclui várias votações)
#' @examples
#' votos <- fetch_votos_por_ano(2190355, 2019)
fetch_votos_por_ano <- function(id_proposicao, ano = 2019) {
  library(tidyverse)
  source(here("crawler/votacoes/utils_votacoes.R"))

  if (is.na(id_proposicao)) {
    data <- tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  }
  
  xml <- fetch_xml_api_votacao(id_proposicao)
  
  votacoes_filtradas <- fetch_votacoes_por_ano(id_proposicao, ano, xml) %>% 
    select(obj_votacao, data, cod_sessao, hora, id_votacao)
  
  votos_raw <- tibble(cod_sessao = votacoes_filtradas$cod_sessao,
                      hora = votacoes_filtradas$hora
                      ) %>%
    mutate(dados = map2(
      cod_sessao,
      hora,
      fetch_votos_por_sessao,
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

#' @title Recupera informações das votações nominais do plenário em um intervalo de tempo (anos)
#' @description A partir de um ano de início e um ano de fim, recupera dados de 
#' votações nominais de plenário que aconteceram na Câmara dos Deputados
#' @param ano_inicial Ano inicial do período de votações
#' @param ano_final Ano final do período de votações
#' @return Votações da proposição em um intervalo de tempo (anos)
#' @examples
#' votacoes <- fetch_all_votacoes_por_intervalo()
fetch_all_votacoes_por_intervalo <- function(ano_inicial = 2015, ano_final = 2019) {
  anos <- seq(ano_inicial, ano_final, 1)
  
  proposicoes_votadas <-
    purrr::map_df(anos, ~ fetch_votacoes_ano(.x)) %>%
    mutate(ano_votacao = lubridate::dmy(data_votacao) %>%
             lubridate::year()) %>%
    distinct(id, ano_votacao)
  
  votacoes <-
    purrr::map2_df(
      proposicoes_votadas$id,
      proposicoes_votadas$ano_votacao,
      ~ fetch_votacoes_por_ano(.x, .y)
    ) %>%
    distinct(id_proposicao, obj_votacao, data, cod_sessao, hora, id_votacao)
  
  return(votacoes)
}
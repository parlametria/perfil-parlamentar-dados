library(tidyverse)


#' @title Importa e processa dados das orientações das bancadas na Câmara dos Deputados
#' @description Recebe informações da proposição e da votação específica para obtenção dos votos
#' @param id_proposicao Id da prposição para obtenção das orientações
#' @param id_votacao Id da votação no contexto interno do Voz Ativa
#' @param resumo_votacao Resumo da Votação
#' @param objeto_votacao Objeto da Votação
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- fetch_orientacoes_camara(2165578, 8334)
fetch_orientacoes_camara <-
  function(id_proposicao,
           id_votacao,
           resumo_votacao,
           objeto_votacao) {
    library(xml2)
    source(here("crawler/votacoes/utils_votacoes.R"))
    
    proposicoes <-
      get_sigla_by_id(id_proposicao) %>%
      select(siglaTipo, numero, ano)
    
    url <-
      paste0(
        "https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=",
        proposicoes$siglaTipo,
        "&numero=",
        proposicoes$numero,
        "&ano=",
        proposicoes$ano
      )
    
    print(
      paste0(
        "Baixando votação da ",
        proposicoes$siglaTipo,
        " ",
        proposicoes$numero,
        "/",
        proposicoes$ano
      )
    )
    
    xml <- RCurl::getURL(url) %>%
      read_xml()
    
    votacao <- xml_find_all(xml, ".//Votacao") %>%
      map_df(function(x) {
        list(
          obj_votacao = xml_attr(x, "ObjVotacao"),
          resumo = xml_attr(x, "Resumo"),
          cod_sessao = xml_attr(x, "codSessao"),
          data = as.Date(xml_attr(x, "Data"), "%d/%m/%Y")
        )
      })
    
    ## Escolhe votação específica
    if (nrow(votacao) > 1) {
      if (is.na(resumo_votacao)) {
        votacao <- votacao %>%
          mutate(obj_votacao = trimws(obj_votacao, which = "both")) %>%
          filter(obj_votacao == trimws(objeto_votacao, "both"))
      } else {
        votacao <- votacao %>%
          mutate(resumo = trimws(resumo, which = "both")) %>%
          filter(resumo == trimws(resumo_votacao, "both"))
      }
    }
    
    orientacoes <-
      xml2::xml_find_all(
        xml,
        paste0(
          ".//Votacao[@ObjVotacao = '",
          votacao$obj_votacao,
          "']",
          "//orientacaoBancada//bancada"
        )
      ) %>%
      map_df(function(x) {
        list(
          sigla = xml_attr(x, "Sigla") %>%
            gsub(" ", "", .),
          voto = xml_attr(x, "orientacao") %>%
            gsub(" ", "", .)
        )
      })
    
    orientacoes <-
      purrr::map2_df(orientacoes$sigla, orientacoes$voto, ~ mutate_sigla(.x, .y)) %>%
      mutate(
        sigla = padroniza_sigla(sigla),
        id_votacao = id_votacao,
        data = votacao$data
      ) %>%
      select(id_votacao,
             data,
             id_parlamentar_voz = sigla,
             voto = orientacao)
    
    return(orientacoes)
  }

#' @title Separa orientações de bancadas compostas
#' @description Caso uma bancada possua mais de um partido, esta função retorna um dataset contendo as informações de cada bancada
#' separadamente
#' @param sigla Sigla da bancada
#' @param orientacao Orientação da bancada
#' @return Dataframe contendo a sigla e a orientação da bancada
#' @examples
#' mutate_sigla("PpPodePTdoB", "Sim")
mutate_sigla <- function(sigla, orientacao) {
  siglas <-
    strsplit(sigla, "(?<=[a-z])(?=[A|D-Z])", perl = TRUE) %>%
    unlist()
  
  if (length(siglas) > 0) {
    df <- map_df(siglas, function(x) {
      return(tribble(~ sigla, ~ orientacao,
                     x, orientacao))
    })
  } else{
    return(tribble(~ sigla, ~ orientacao))
  }
}

#' @title Recupera informações da orientação dos partidos para um conjunto de votações
#' @description Recupera para cada votação informações sobre a orientação dos partidos
#' @param votacoes_datapath Caminho para o arquivo csv com as votações
#' @return Dataframe contendo a orientação dos partidos
#' @examples
#' fetch_orientacoes_votacoes(here::here("crawler/raw_data/tabela_votacoes.csv"))
fetch_orientacoes_votacoes <- function(votacoes_datapath = here::here("crawler/raw_data/tabela_votacoes.csv")) {
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  votacoes <-
    readr::read_csv(votacoes_datapath, col_types = "cicccccccc")
  
  votacoes <- votacoes %>%
    dplyr::filter(casa == "camara") %>%
    dplyr::filter(!is.na(id_sessao)) %>%
    dplyr::select(id_proposicao, id_sessao, resumo, objeto_votacao)
  
  orientacoes <- purrr::pmap_dfr(
    list(
      votacoes$id_proposicao,
      votacoes$id_sessao,
      votacoes$resumo,
      votacoes$objeto_votacao
    ),
    ~ fetch_orientacoes_camara(..1, ..2, ..3, ..4)
  ) %>%
    enumera_voto()
  
  return(orientacoes)
}

#' @title Recupera informações da orientação dos partidos e salva num csv
#' @description Recupera para cada votação informações sobre a orientação dos partidos e salva num csv
#' @param votacoes_datapath Caminho para o arquivo csv com as votações
#' @return Dataframe contendo a orientação dos partidos
#' @examples
#' fetch_all_orientacoes(here::here("crawler/raw_data/tabela_votacoes.csv"))
fetch_all_orientacoes <- function(votacoes_datapath = here::here("crawler/raw_data/tabela_votacoes.csv")) {
    orientacoes <- fetch_orientacoes_votacoes()
    
    readr::write_csv(orientacoes,
                     here::here("crawler/raw_data/orientacoes.csv"))
    
    return(orientacoes)
}

#' @title Importa e processa dados das orientações das bancadas na Câmara dos Deputados para uma proposição
#' @description A partir do ID da proposição recupera votações que ocorreram no ano passado como parâmetro
#' @param id_proposicao Id da prposição para obtenção das orientações
#' @param ano Ano em que as votações ocorreram
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' orientacoes <- fetch_orientacoes_por_proposicao(2190355, 2019)
fetch_orientacoes_por_proposicao <- function(id_proposicao, ano = 2019) {
    library(tidyverse)
    library(xml2)
    source(here("crawler/votacoes/utils_votacoes.R"))

    source(here("crawler/votacoes/utils_votacoes.R"))
    
    proposicao <- get_sigla_by_id(id_proposicao) %>%
      select(siglaTipo, numero, ano)
    
    url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=", 
                  proposicao$siglaTipo, "&numero=", proposicao$numero, "&ano=", proposicao$ano)
    
    print(paste0("Baixando votação da ", proposicao$siglaTipo, " ", proposicao$numero, "/", proposicao$ano))
    
    xml <- RCurl::getURL(url) %>%
      read_xml()
    
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
    
    votacoes_filtradas <- votacoes %>% 
      mutate(ano_votacao = format(data, "%Y")) %>% 
      filter(ano_votacao == ano) %>% 
      mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>% 
      select(obj_votacao, data, cod_sessao, hora, id_votacao)
    
    orientacoes <- tibble(cod_sessao = votacoes_filtradas$cod_sessao,
                          hora = votacoes_filtradas$hora) %>%
      mutate(dados = map2(
        cod_sessao,
        hora,
        fetch_orientacao_from_xml,
        xml
      )) %>% 
      unnest(dados) %>% 
      select(id_votacao, partido, voto)
    
    return(orientacoes)
}

#' @title Recupera orientações das bancadas para uma votação específica
#' @description A partir do código da sessão e da hora extrai as orientações das bancadas contidas num xml
#' @param cod_sessao Código da sessão da votação
#' @param hora Hora da votação
#' @param xml XML com informaçãoo das votações
#' @return Dataframe contendo id da votação, id e voto dos deputados que participaram de cada votação
#' @examples
#' orientacoes <- fetch_orientacao_from_xml("16821", "19:57", xml)
fetch_orientacao_from_xml <- function(cod_sessao, hora, xml) {
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  orientacoes_raw <- xml2::xml_find_all(xml, paste0(".//Votacao[@codSessao = '", cod_sessao,"' and @Hora = '", hora,"']", 
                                   "//orientacaoBancada//bancada")) %>%
    map_df(function(x) {
      list(
        sigla = xml_attr(x, "Sigla") %>%
          gsub(" ", "", .),
        orientacao = xml_attr(x, "orientacao") %>%
          gsub(" ", "", .)
      )
    })
  
  orientacoes <- purrr::map2_df(orientacoes_raw$sigla, orientacoes_raw$orientacao, ~ mutate_sigla(.x, .y)) %>%
    mutate(sigla = padroniza_sigla(sigla),
           id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>%
    select(id_votacao,
           partido = sigla,
           voto = orientacao) %>% 
    enumera_voto() %>% 
    distinct()
  
  return(orientacoes)
}

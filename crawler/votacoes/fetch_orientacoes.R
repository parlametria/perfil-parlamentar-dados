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
    proposicoes <-
      rcongresso::fetch_proposicao_camara(id_proposicao) %>%
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
        sigla = toupper(sigla),
        sigla =
          case_when(
            str_detect(tolower(sigla), "ptdob") ~ "AVANTE",
            str_detect(tolower(sigla), "pcdob") ~ "PCdoB",
            str_detect(tolower(sigla), "ptn") ~ "PODEMOS",
            str_detect(tolower(sigla), "pmdb") ~ "MDB",
            str_detect(sigla, "SOLID.*") ~ "SOLIDARIEDADE",
            str_detect(sigla, "PODE.*") ~ "PODEMOS",
            str_detect(sigla, "GOV.") ~ "GOVERNO",
            TRUE ~ sigla
          ) %>%
          stringr::str_replace("REPR.", ""),
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

#' @title Enumera votações
#' @description Recebe um dataframe com coluna orientacao e enumera o valor para um número
#' @param df Dataframe com a coluna orientacao
#' @return Dataframe com coluna orientacao enumerada
#' @examples
#' enumera_votacoes(df)
enumera_voto <- function(df) {
  df %>%
    mutate(
      voto = case_when(
        str_detect(voto, "Não") ~ -1,
        str_detect(voto, "Sim") ~ 1,
        str_detect(voto, "Obstrução") ~ 2,
        str_detect(voto, "Abstenção") ~ 3,
        str_detect(voto, "Art. 17") ~ 4,
        TRUE ~ 0
      )
    )
}
#' @title Recupera informações de composição das comissões usando o LeggoR a partir de uma data de inicio
#' @description Utiliza o LeggoR para recuperar informações sobre a composição dos membros das composições do Congresso a partir de uma data
#' @param data_inicio Data inicial (formato AAAA-MM-DD)
#' @return Dataframe com parlamentares membros da comissão e seus respectivos cargos
#' @examples
#' fetch_comissoes_composicao_camara()
fetch_comissoes_composicao_camara <- function(data_inicio = '2019-12-22') {
  library(tidyverse)
  library(agoradigital)
  # devtools::install_github('analytics-ufcg/leggoR', force = T)
  
  orgaos <- agoradigital::fetch_orgaos_camara() %>% 
    filter(tipoOrgao == 'Comissão Permanente') %>% 
    select(orgao_id, sigla)
  
  comissoes <- purrr::map2_df(orgaos$orgao_id, 
                              orgaos$sigla,
                              ~ fetch_membros_comissao_camara_with_backoff(.x, .y, data_inicio)) %>% 
    dplyr::select(id, nome, cargo, situacao, sigla, casa) %>% 
    dplyr::distinct()
  
  return(comissoes)
}

#' @title Recupera informações de composição das comissões usando o LeggoR
#' @description Utiliza o LeggoR para recuperar informações sobre a composição dos membros das composições do Congresso
#' @return Dataframe com parlamentares membros da comissão e seus respectivos cargos
#' @examples
#' fetch_comissoes_composicao_senado()
fetch_comissoes_composicao_senado <- function() {
  library(tidyverse)
  library(agoradigital)
  # devtools::install_github('analytics-ufcg/leggoR', force = T)
  
  comissoes <- agoradigital::fetch_all_composicao_comissao() %>% 
    dplyr::mutate(id_senado = stringr::str_match(foto, "fotos-oficiais/senador(.*?).jpg")[,2]) %>% 
    dplyr::filter(casa == "senado") %>% 
    dplyr::filter(nome != "", nome != "VAGO", id_senado != "") %>%
    dplyr::mutate(cargo = dplyr::if_else(is.na(cargo), 
                                         situacao,
                                         cargo)) %>% 
    dplyr::mutate(cargo = dplyr::if_else(cargo == "RELATOR",
                                         situacao,
                                         cargo)) %>% # Checagem adicional que irá sair quando o erro da API (Senado) for corrigido 
    dplyr::select(id = id_senado, nome, cargo, situacao, sigla, casa) %>% 
    dplyr::distinct()
  
  return(comissoes)
}

#' @title Recupera informações da Comissão na Câmara dos Deputados
#' @description Utiliza o rcongresso para recuperar informações sobre uma Comissão específica na câmara dos deputados
#' @param sigla_comissao Sigla da Comissão
#' @return Dataframe com informações da Comissão
#' @examples
#' fetch_comissao_info_camara("CCJC")
fetch_comissao_info_camara <- function(sigla_comissao) {
  library(tidyverse)
  library(agoradigital)
  
  comissao_info <- agoradigital::fetch_orgaos_camara() %>% 
    dplyr::filter(sigla == sigla_comissao) %>% 
    dplyr::select(comissao_id = orgao_id, nome_comissao = descricao)
  
  return(comissao_info)
}

#' @title Recupera informações da Comissão no Senado Federal
#' @description Utiliza o rcongresso para recuperar informações sobre uma Comissão específica no Senado
#' @param sigla Sigla da Comissão
#' @return Dataframe com informações da Comissão
#' @examples
#' fetch_comissao_info_senado("CAE")
fetch_comissao_info_senado <- function(sigla) {
  library(tidyverse)
  
  url <- paste0("http://legis.senado.leg.br/dadosabertos/comissao/", sigla)
  
  comissao <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//COLEGIADO_ROW") %>%
      map_df(function(x) {
        list(
          comissao_id = xml2::xml_find_first(x, ".//CODIGO") %>% 
            xml2::xml_text(),
          sigla = xml2::xml_find_first(x, ".//SGL_COLEGIADO") %>% 
            xml2::xml_text(),
          nome_comissao = xml2::xml_find_first(x, ".//COLEGIADO") %>% 
            xml2::xml_text()
        )
      }) %>% 
      dplyr::mutate(comissao_id = as.numeric(comissao_id)) %>% 
      dplyr::select(comissao_id, nome_comissao)
  }, error = function(e) {
    data <- tribble(
      ~ comissao_id, ~ sigla, ~ nome_comissao)
    return(data)
  })
  
  return(comissao)
}

#' @title Recupera informações da Comissão
#' @description Utiliza o rcongresso para recuperar informações sobre uma Comissão específica
#' @param sigla Sigla da Comissão
#' @return Dataframe com informações da Comissão
#' @examples
#' fetch_comissao_info("CCJC", "camara")
fetch_comissao_info <- function(sigla, casa) {
  library(tidyverse)
  library(rcongresso)
  
  if (casa == "camara") {
    return(fetch_comissao_info_camara(sigla))
  } else {
    return(fetch_comissao_info_senado(sigla))
  }
}

#' @title Recupera informações dos membros de uma Comissão em uma data de inicio específica
#' @description A partir de um id, retorna os membros daquela comissão a partir da data de início especificada
#' @param orgao_id Id da Comissão
#' @param sigla_comissao Sigla da Comissão
#' @param data_inicio Data inicial de interesse (formato AAAA-MM-DD)
#' @param max_tentativas Número máximo de tentativas
#' @return Dataframe com informações dos membros da Comissão para uma data de início
fetch_membros_comissao_camara_with_backoff <- function(orgao_id, sigla_comissao, data_inicio = '2019-12-22', max_tentativas = 10) {
  library(tidyverse)
  
  print(paste0('Baixando informações dos membros da comissão ', sigla_comissao, ' na casa camara'))
  url <- paste0('https://dadosabertos.camara.leg.br/api/v2/orgaos/',
                orgao_id, 
                '/membros?dataInicio=', 
                data_inicio, 
                '&itens=100')
  
  links <- (RCurl::getURL(url) %>% jsonlite::fromJSON())$links
  
  last_page <- links %>% 
    filter(rel == "last") %>% 
    pull(href) %>% 
    str_match("pagina=(.*?)&") %>% 
    tibble::as_tibble(.name_repair = c("universal")) %>% 
    pull(`...2`)
  
  membros <- tibble(page = 1:as.numeric(last_page)) %>%
    mutate(data = map(
      page,
      fetch_membros_comissao_camara_by_page,
      url,
      sigla_comissao,
      max_tentativas
    )) %>% 
    unnest(data)
  

}

#' @title Recupera informações dos membros de uma Comissão em uma data de inicio específica
#' @description A partir de um id, retorna os membros daquela comissão a partir da data de início especificada
#' @param page Página a ser requisitada
#' @param url Url da requisição
#' @param max_tentativas Número máximo de tentativas
#' @return Dataframe com informações dos membros da Comissão para uma data de início
fetch_membros_comissao_camara_by_page <- function(page = 1,  url, sigla_comissao, max_tentativas = 10) {
  library(tidyverse)
  
  url_paginada <- paste0(url, '&pagina=', page)
  
  for (tentativa in seq_len(max_tentativas)) {
    
    membros <- tryCatch(
      {
        membros <-
          (RCurl::getURL(url_paginada) %>% 
             jsonlite::fromJSON())$dados %>% 
          as_tibble()
        
        if (nrow(membros) == 0) {
          return(tibble::tribble(~ cargo, ~ id, ~ nome, ~ partido, ~ uf, ~ situacao))
        } else {
          
          membros <- membros %>% 
            dplyr::select(cargo = titulo, id, nome, partido = siglaPartido, uf = siglaUf) %>%
            dplyr::mutate(sigla = sigla_comissao, 
                          casa = "camara",
                          cargo = dplyr::case_when(
                            startsWith(cargo, "Presidente") ~ "PRESIDENTE",
                            startsWith(cargo, "Titular") ~ "TITULAR",
                            startsWith(cargo, "1º Vice-Presidente") ~ "PRIMEIRO VICE-PRESIDENTE",
                            startsWith(cargo, "Suplente") ~ "SUPLENTE",
                            startsWith(cargo, "2º Vice-Presidente") ~ "SEGUNDO VICE-PRESIDENTE",
                            startsWith(cargo, "3º Vice-Presidente") ~ "TERCEIRO VICE-PRESIDENTE"
                          ),
                          situacao = if_else(cargo == 'SUPLENTE', 'Suplente', 'Titular'))
          membros <- membros[!duplicated(membros$id) | membros$cargo %in% 
                               c("PRESIDENTE", "VICE-PRESIDENTE", "SEGUNDO VICE-PRESIDENTE", "TERCEIRO VICE-PRESIDENTE"),,drop=FALSE]
        }
        return(membros)
      }, error = function(e) {
        print(e)
        return(tibble::tribble(~ cargo, ~ id, ~ nome, ~ partido, ~ uf, ~ situacao))
      }
    )
    
    if (nrow(membros) == 0) {
      backoff <- runif(n = 1, min = 0, max = 2 ^ tentativa - 1)
      message("Backing off for ", backoff, " seconds.")
      Sys.sleep(backoff)
    } else {
      break
    }
  }
  return(membros)
}
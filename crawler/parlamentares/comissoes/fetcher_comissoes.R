#' @title Recupera informações de composição das comissões usando o LeggoR a partir de uma data de inicio
#' @description Utiliza o LeggoR para recuperar informações sobre a composição dos membros das composições do Congresso a partir de uma data
#' @param data_inicio Data inicial (formato AAAA-MM-DD)
#' @return Dataframe com parlamentares membros da comissão e seus respectivos cargos
#' @examples
#' fetch_comissoes_composicao_camara()
fetch_comissoes_composicao_camara <- function(data_inicio = '2019-02-01') {
  library(tidyverse)
  library(agoradigital)
  # devtools::install_github('analytics-ufcg/leggoR', force = T)
  
  comissoes <- agoradigital::fetch_all_composicao_comissao(data_inicio) %>% 
    filter(casa == "camara") %>% 
    dplyr::select(id, nome, cargo, situacao, sigla, casa, data_inicio, data_fim) %>% 
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
    dplyr::select(id = id_senado, nome, cargo, situacao, sigla, casa, data_inicio, data_fim) %>% 
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
  
  url <- paste0("https://legis.senado.leg.br/dadosabertos/comissao/", sigla)
  
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

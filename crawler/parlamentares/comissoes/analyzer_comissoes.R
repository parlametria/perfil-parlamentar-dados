#' @title Recupera informações de composição das comissões usando o LeggoR
#' @description Utiliza o LeggoR para recuperar informações sobre a composição dos membros das composições do Congresso
#' @return Dataframe com parlamentares membros da comissão e seus respectivos cargos
#' @examples
#' fetch_comissoes_composicao_camara()
fetch_comissoes_composicao_camara <- function() {
  library(tidyverse)
  library(agoradigital)
  # devtools::install_github('analytics-ufcg/leggoR', force = T)
  
  comissao_educacao <- agoradigital::fetch_orgaos_camara() %>% 
    dplyr::filter(orgao_id == 2009)
  
  comissoes <- agoradigital::fetch_all_composicao_comissao() %>% 
    dplyr::filter(casa == "camara") %>% 
    dplyr::bind_rows(agoradigital::fetch_composicao_comissao(
      sigla = "CE", casa = "camara", 
      orgaos_camara = comissao_educacao)) %>% 
    dplyr::select(id, nome, cargo, situacao, sigla)
  
  return(comissoes)
}

#' @title Recupera informações da Comissão na Câmara dos Deputados
#' @description Utiliza o LeggoR para recuperar informações sobre uma Comissão específica na câmara dos deputados
#' @param sigla Sigla da Comissão
#' @return Dataframe com informações da Comissão
#' @examples
#' fetch_comissao_info_camara()
fetch_comissao_info_camara <- function(sigla) {
  library(tidyverse)
  library(rcongresso)
  
  comissao_info <- rcongresso::fetch_orgao_camara(sigla) %>% 
    dplyr::select(comissao_id = id, nome_comissao = nome)

  return(comissao_info)
}

#' @title Padroniza nomenclatura do cargo de um parlamentar numa Comissão
#' @description Padroniza nomenclatura do cargo de um parlamentar numa Comissão
#' @param cargo Cargo para padronização
#' @return String com Nome Padronizado
#' @examples
#' padroniza_cargo_comissao_camara("Titular")
padroniza_cargo_comissao_camara <- function(cargo) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  cargo_padronizado = dplyr::case_when(cargo == tolower(.PRESIDENTE) ~ "Presidente",
                                       cargo == tolower(.PRIMEIRO_VICE_PRESIDENTE) ~ "Primeiro Vice-presidente",
                                       cargo == tolower(.SEGUNDO_VICE_PRESIDENTE) ~ "Segundo Vice-presidente",
                                       cargo == tolower(.TERCEIRO_VICE_PRESIDENTE) ~ "Terceiro Vice-presidente",
                                       startsWith(cargo, .TITULAR) ~ "Titular",
                                       startsWith(cargo, .SUPLENTE) ~ "Suplente")
  
  return(cargo_padronizado)
}


#' @title Atribui um peso ao cargo do parlamentar na Comissão
#' @description Classifica cargos da Comissão de acordo com o nível do cargo
#' @param cargo Cargo para padronização
#' @param situacao Situação do parlamentar na Comissão
#' @return Valor atribuído ao cargo
#' @examples
#' enumera_cargo_comissao_camara("Titular")
enumera_cargo_comissao_camara <- function(cargo, situacao) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  peso = dplyr::case_when(cargo == tolower(.PRESIDENTE) ~ 7,
                          cargo == tolower(.PRIMEIRO_VICE_PRESIDENTE) ~ 6,
                          cargo == tolower(.SEGUNDO_VICE_PRESIDENTE) ~ 5,
                          cargo == tolower(.TERCEIRO_VICE_PRESIDENTE) ~ 4,
                          startsWith(cargo, .TITULAR) ~ 3,
                          startsWith(cargo, .SUPLENTE) ~ 2,
                          is.na(cargo) & situacao == .TITULAR ~ 1,
                          TRUE ~ 0)
  
  return(peso)
}

#' @title Recupera informações das Comissões e de suas composições
#' @description Retorna dados de Comissões da Câmara dos Deputados e também suas composições
#' @return Lista com dois Dataframes: comissões e composição das comissões
#' @examples
#' processa_comissoes_composicao_camara()
processa_comissoes_composicao_camara <- function() {
  library(tidyverse)
  
  comissao_composicao <- fetch_comissoes_composicao_camara()
  
  lista_comissao <- comissao_composicao %>% 
    dplyr::distinct(sigla) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(dados = purrr::map(sigla, 
                       fetch_comissao_info_camara)) %>% 
    tidyr::unnest(dados)
  
  ## Composição das Comissões
  composicao_comissoes <- comissao_composicao %>% 
    dplyr::left_join(lista_comissao, by = c("sigla")) %>% 
    
    dplyr::mutate(peso_cargo = enumera_cargo_comissao_camara(tolower(cargo), tolower(situacao))) %>% 
    dplyr::mutate(cargo = padroniza_cargo_comissao_camara(tolower(cargo))) %>% 
    
    dplyr::group_by(comissao_id, id) %>% 
    dplyr::mutate(maximo = max(peso_cargo)) %>%
    dplyr::filter(maximo == peso_cargo) %>% 
    
    dplyr::mutate(casa = "camara") %>% 
    dplyr::select(comissao_id, casa, id_parlamentar = id, cargo, situacao)

  ## Informações das Comissões
  comissoes <- lista_comissao %>% 
    dplyr::mutate(casa = "camara") %>% 
    dplyr::select(id = comissao_id, casa, sigla, nome = nome_comissao)
  
  return(list(comissoes, composicao_comissoes))
}

#' @title Recupera informações das Comissões e de suas composições
#' @description Retorna dados de Comissões do Congresso Nacional e também suas composições
#' @return Lista com dois Dataframes: comissões e composição das comissões
#' @examples
#' processa_comissoes_composicao()
processa_comissoes_composicao <- function() {
  library(tidyverse)
  
  dados_comissoes_camara <- processa_comissoes_composicao_camara()
  
  comissoes_camara <- dados_comissoes_camara[[1]]
  composicao_comissoes_camara <- dados_comissoes_camara[[2]]
  
  return(list(comissoes_camara, composicao_comissoes_camara))
}

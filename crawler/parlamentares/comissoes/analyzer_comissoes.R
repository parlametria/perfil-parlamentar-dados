#' @title Recupera informações de composição das comissões usando o LeggoR
#' @description Utiliza o LeggoR para recuperar informações sobre a composição dos membros das composições do Congresso
#' @return Dataframe com parlamentares membros da comissão e seus respectivos cargos
#' @examples
#' fetch_comissoes()
fetch_comissoes_composicao <- function() {
  library(tidyverse)
  library(agoradigital)
  # devtools::install_github('analytics-ufcg/leggoR', force = T)
  
  comissoes <- agoradigital::fetch_all_composicao_comissao() %>% 
    dplyr::filter(casa == "camara") %>% 
    dplyr::select(id, nome, cargo, situacao, sigla)
  
  return(comissoes)
}

#' @title Recupera informações da Comissão na Câmara dos Deputados
#' @description Utiliza o LeggoR para recuperar informações sobre uma Comissão específica na câmara dos deputados
#' @param sigla Sigla da Comissão
#' @return Dataframe com informações da Comissão
#' @examples
#' fetch_comissoes_info()
fetch_comissao_info <- function(sigla) {
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
#' padroniza_cargo_comissao("Titular")
padroniza_cargo_comissao <- function(cargo) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  cargo_padronizado = dplyr::case_when(cargo == .PRESIDENTE ~ "Presidente",
                                       cargo == .PRIMEIRO_VICE_PRESIDENTE ~ "Primeiro Vice-presidente",
                                       cargo == .SEGUNDO_VICE_PRESIDENTE ~ "Segundo Vice-presidente",
                                       cargo == .TERCEIRO_VICE_PRESIDENTE ~ "Terceiro Vice-presidente",
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
#' padroniza_cargo_comissao("Titular")
enumera_cargo_comissao <- function(cargo, situacao) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  peso = dplyr::case_when(cargo == .PRESIDENTE ~ 7,
                          cargo == .PRIMEIRO_VICE_PRESIDENTE ~ 6,
                          cargo == .SEGUNDO_VICE_PRESIDENTE ~ 5,
                          cargo == .TERCEIRO_VICE_PRESIDENTE ~ 4,
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
#' processa_comissoes_composicao()
processa_comissoes_composicao <- function() {
  library(tidyverse)
  
  comissao_composicao <- fetch_comissoes_composicao()
  
  lista_comissao <- comissao_composicao %>% 
    dplyr::distinct(sigla) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(dados = purrr::map(sigla, 
                       fetch_comissao_info)) %>% 
    tidyr::unnest(dados)
  
  ## Composição das Comissões
  composicao_comissoes <- comissao_composicao %>% 
    dplyr::left_join(lista_comissao, by = c("sigla")) %>% 
    
    dplyr::mutate(peso_cargo = enumera_cargo_comissao(cargo, situacao)) %>% 
    dplyr::mutate(cargo = padroniza_cargo_comissao(cargo)) %>% 
    
    dplyr::group_by(comissao_id, id) %>% 
    dplyr::mutate(maximo = max(peso_cargo)) %>%
    dplyr::filter(maximo == peso_cargo) %>% 
    
    dplyr::select(comissao_id, parlamentar_id = id, cargo, situacao)

  ## Informações das Comissões
  comissoes <- lista_comissao %>% 
    dplyr::select(id = comissao_id, sigla, nome = nome_comissao)
  
  return(list(comissoes, composicao_comissoes))
}

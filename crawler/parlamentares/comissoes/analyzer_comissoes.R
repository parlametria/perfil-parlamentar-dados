#' @title Padroniza nomenclatura do cargo de um parlamentar numa Comissão
#' @description Padroniza nomenclatura do cargo de um parlamentar numa Comissão
#' @param cargo Cargo para padronização
#' @return String com Nome Padronizado
#' @examples
#' padroniza_cargo_comissao("Titular")
padroniza_cargo_comissao <- function(cargo) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  cargo_padronizado = dplyr::case_when(cargo == tolower(.PRESIDENTE) ~ "Presidente",
                                       cargo == tolower(.VICE_PRESIDENTE) ~ "Vice-presidente",
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
#' enumera_cargo_comissao("Titular")
enumera_cargo_comissao <- function(cargo, situacao) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/comissoes/constants/cargos.R"))
  
  peso = dplyr::case_when(cargo == tolower(.PRESIDENTE) ~ 7,
                          cargo == tolower(.VICE_PRESIDENTE) ~ 6,
                          cargo == tolower(.PRIMEIRO_VICE_PRESIDENTE) ~ 6,
                          cargo == tolower(.SEGUNDO_VICE_PRESIDENTE) ~ 5,
                          cargo == tolower(.TERCEIRO_VICE_PRESIDENTE) ~ 4,
                          startsWith(cargo, tolower(.TITULAR)) ~ 3,
                          startsWith(cargo, tolower(.SUPLENTE)) ~ 2,
                          is.na(cargo) & situacao == tolower(.TITULAR) ~ 1,
                          TRUE ~ 0)
  
  return(peso)
}

#' @title Recupera informações das Comissões e de suas composições
#' @description Retorna dados de Comissões da Câmara dos Deputados e também suas composições
#' @return Lista com dois Dataframes: comissões e composição das comissões
#' @examples
#' processa_comissoes()
processa_comissoes <- function() {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/comissoes/fetcher_comissoes.R"))
  
  comissao_composicao_camara <- fetch_comissoes_composicao_camara()
  
  comissao_composicao_senado <- fetch_comissoes_composicao_senado()
  
  comissao_composicao <- comissao_composicao_camara %>% 
    rbind(comissao_composicao_senado)
  
  lista_comissao <- comissao_composicao %>% 
    dplyr::distinct(casa, sigla) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(dados = purrr::map2(sigla, 
                                      casa,
                                      fetch_comissao_info)) %>% 
    tidyr::unnest(dados) %>% 
    dplyr::mutate(nome_comissao = stringr::str_to_title(nome_comissao))
  
  ## Composição das Comissões
  composicao_comissoes <- comissao_composicao %>% 
    dplyr::left_join(lista_comissao, by = c("sigla", "casa")) %>% 
    
    dplyr::mutate(peso_cargo = enumera_cargo_comissao(tolower(cargo), tolower(situacao))) %>% 
    dplyr::mutate(cargo = padroniza_cargo_comissao(tolower(cargo))) %>% 
    
    dplyr::group_by(comissao_id, id) %>% 
    dplyr::mutate(maximo = max(peso_cargo)) %>%
    dplyr::filter(maximo == peso_cargo) %>% 
    
    dplyr::select(comissao_id, casa, id_parlamentar = id, cargo, situacao)

  ## Informações das Comissões
  comissoes <- lista_comissao %>%
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
  
  dados_comissoes <- processa_comissoes()
  
  comissoes <- dados_comissoes[[1]]
  composicao_comissoes <- dados_comissoes[[2]]
  
  return(list(comissoes, composicao_comissoes))
}

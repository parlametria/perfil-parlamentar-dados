#' @title Recupera e processa dados de proposições consideradas no cálculo de aderência para o Voz Ativa
#' @description A partir do link para a planilha com as proposições votadas na legislatura atual e selecionadas
#' para o cálculo de aderência no Voz Ativa processa esses dados para um formato padrão.
#' @param url URL para os dados de proposições votadas na legislatura atual
#' @return Dataframe com o formato padrão para os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_plenario_selecionadas(url)
fetch_proposicoes_plenario_selecionadas <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_CAMARA
  }
  
  proposicoes <- read_csv(url, col_types = cols(id = "c"))
  
  proposicoes_va <- proposicoes %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    mutate(descricao = NA,
           status_proposicao = "Inativa",
           status_importante = "Ativa",
           casa = "camara") %>%
    select(id_proposicao = id, casa, projeto_lei = nome, titulo = `Sugestões de apelido`, descricao, status_proposicao, status_importante)
}

#' @title Recupera e processa dados das proposições escolhidas como posições para o questionário do Voz Ativa
#' @description A partir dos dados das votações escolhidas para o questionário processa as proposições para o
#' formato padrão
#' @param url URL para os dados de votações escolhidas para o questionário Voz Ativa
#' @return Dataframe com o formato padrão para os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_questionario(data_path)
fetch_proposicoes_questionario <- function(url = NULL) {
  library(tidyverse)
  library(here)

  if(is.null(url)) {
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_VOZATIVA
  }
  
  proposicoes <- read_csv(url, col_types = cols(id_proposicao = "c"))
  
  proposicoes_va <- proposicoes %>%
    select(id_proposicao, casa, projeto_lei = numero_proj_lei, titulo = apelido, descricao = `o que é isso?`, status_proposicao, status_importante)
  
  return(proposicoes_va)
}

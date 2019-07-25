#' @title Recupera e processa dados de proposições consideradas no cálculo de aderência para o Voz Ativa
#' @description A partir do link para a planilha com as proposições votadas na legislatura atual e selecionadas
#' para o cálculo de aderência no Voz Ativa processa esses dados para um formato padrão.
#' @param url URL para os dados de proposições votadas na legislatura atual
#' @return Dataframe com o formato padrão para os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_plenario_selecionadas(url)
fetch_proposicoes_plenario_selecionadas <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSvvT0fmGUMwOHnEPe9hcAMC_l-u9d7sSplNYkMMzgiE_vFiDcWXWwl4Ys7qaXuWwx4VcPtFLBbMdBd/pub?gid=399933255&single=true&output=csv") {
  library(tidyverse)
  
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
fetch_proposicoes_questionario <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTMcbeHRm_dqX-i2gNVaCiHMFg6yoIjNl9cHj0VBIlQ5eMX3hoHB8cM8FGOukjfNajWDtfvfhqxjji7/pub?gid=0&single=true&output=csv") {
  library(tidyverse)
  library(here)
  
  proposicoes <- read_csv(url, col_types = cols(id_proposicao = "c"))
  
  proposicoes_va <- proposicoes %>%
    select(id_proposicao, casa, projeto_lei = numero_proj_lei, titulo = apelido, descricao = `o que é isso?`, status_proposicao, status_importante)
  
  return(proposicoes_va)
}

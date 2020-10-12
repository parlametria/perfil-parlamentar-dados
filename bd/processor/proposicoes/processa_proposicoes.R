#' @title Processa dados de proposições
#' @description Processa os dados de proposições e adiciona o id do tema da proposição
#' @param prop_data_path Caminho para o arquivo de dados de perguntas sem tratamento
#' @return Dataframe com informações das proposições incluindo o id do tema da proposição
processa_proposicoes <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/proposicoes/fetch_proposicoes_voz_ativa.R"))
  source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
  source(here("crawler/proposicoes/utils_proposicoes.R"))
  
  proposicoes_questionario <- fetch_proposicoes_questionario(.URL_PROPOSICOES_VOZATIVA)
  
  proposicoes_plenario <- fetch_proposicoes(casa_aderencia = "camara", selecionadas = 0, proposicoes_url = .URL_PROPOSICOES_PLENARIO_CAMARA)
  
  proposicoes_plenario_senado <- fetch_proposicoes(casa_aderencia = "senado", selecionadas = 0,proposicoes_url = .URL_PROPOSICOES_PLENARIO_SENADO)
  
  proposicoes <- proposicoes_questionario %>% 
    rbind(proposicoes_plenario) %>% 
    rbind(proposicoes_plenario_senado) %>%
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>% 
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    mutate(id_proposicao_voz = paste0(if_else(casa == "camara", 1, 2), 
                                             id_proposicao)) %>% 
    mutate(id_proposicao_voz = as.numeric(id_proposicao_voz)) %>% 
    select(id_proposicao_voz, casa, projeto_lei, titulo, descricao, status_proposicao, status_importante)
  
  return(proposicoes)
}
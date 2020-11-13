#' @title Processa dados dos temas das proposições
#' @description Processa os dados dos temas de proposições
#' @return Dataframe com informações dos temas das proposições (cada tema para cada proposição é uma observação)
processa_proposicoes_temas <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/proposicoes/process_proposicao_tema.R"))
  source(here("crawler/proposicoes/utils_proposicoes.R"))
  
  proposicoes_questionario <-
    process_proposicoes_questionario_temas(.URL_PROPOSICOES_VOZATIVA) %>% 
    mutate(casa = "camara")
  
  proposicoes_plenario <-
    process_proposicoes_plenario_selecionadas_temas(.URL_PROPOSICOES_PLENARIO_CAMARA) %>%
    rbind(process_proposicoes_plenario_temas(casa_aderencia = "camara")) %>%
    mutate(casa = "camara")
  
  proposicoes_plenario_senado <-
    process_proposicoes_plenario_selecionadas_temas(.URL_PROPOSICOES_PLENARIO_SENADO) %>%
    rbind(process_proposicoes_plenario_temas(casa_aderencia = "senado")) %>%
    mutate(casa = "senado")
  
  proposicoes <- proposicoes_questionario %>%
    rbind(proposicoes_plenario) %>%
    rbind(proposicoes_plenario_senado) %>%
    distinct(id_proposicao, casa, id_tema) %>% 
    mutate(id_proposicao_voz = paste0(if_else(casa == "camara", 1, 2), 
                                      id_proposicao)) %>% 
    select(id_proposicao_voz, id_tema)
  
  return(proposicoes)
}
#' @title Processa dados de ligações econômicas dos parlamentares em exercício 
#' @description Cria tabela com informações e índice de ligações com atividades econômicas
#' @param parlamentares_datapath CAminho para o dataframe de parlamentares
#' @return Dataframe com informações de ligações com atividades econômicas
processa_ligacoes_atividades_economicas <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/processor/empresas/processor_indice_atividades_economicas.R"))
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id_parlamentar = id, casa)
  
  parlamentares_ligacoes <- processa_indices_ligacao_atividade_economica()
  
  parlamentares_alt <- parlamentares_ligacoes %>% 
    inner_join(parlamentares, by = c("id_parlamentar", "casa")) %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id_parlamentar))
    ) %>% 
    select(id_parlamentar_voz, grupo_atividade_economica, total_por_atividade, proporcao_doacao, indice_ligacao_atividade_economica)
  
  ## TODO: inserir merge com id do grupo_atividade_economica
  
  return(parlamentares_alt)
}

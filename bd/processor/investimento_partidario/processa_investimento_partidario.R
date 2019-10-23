#' @title Processa dados de investimento partidário
#' @description Processa os dados de investimento partidário e retorna no formato  a ser utilizado pelo banco de dados
#' @param investimento_partidario_path Caminho para o arquivo de dados de investimento partidário sem tratamento
#' @return Dataframe com informações de investimento partidário
processa_investimento_partidario <- function(
  investimento_partidario_path = here::here("parlametria/raw_data/resumo/parlamentares_investimento.csv")) {
  library(tidyverse)
  
  investimento <- read_csv(investimento_partidario_path) %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id))
    )
  
  investimento_alt <- investimento %>% 
    select(id_parlamentar_voz, total_receita_partido, total_receita_candidato, indice_investimento_partido = proporcao_campanhas_medias_receita) %>% 
    distinct(id_parlamentar_voz, .keep_all = TRUE)
  
  return(investimento_alt)
}

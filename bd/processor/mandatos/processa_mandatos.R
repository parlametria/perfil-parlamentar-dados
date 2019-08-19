#' @title Processa dados dos mandatos
#' @description Processa os dados dos mandatos e retorna no formato  a ser utilizado pelo banco de dados
#' @param mandatos_path Caminho para o arquivo de dados de mandatos sem tratamento
#' @return Dataframe com informações dos mandatos
processa_mandatos <- function(mandatos_path = here::here("crawler/raw_data/mandatos.csv")) {
  library(tidyverse)
  
  mandatos <- read.csv(mandatos_path, stringsAsFactors = FALSE)
  
  mandatos <- mandatos %>% 
    mutate(casa_enum = dplyr::if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa_enum, as.character(id_parlamentar)),
           id_mandato_voz = paste0(id_parlamentar_voz, id_legislatura, gsub("-", "", data_inicio))) %>% 
    arrange(cod_causa_fim_exercicio) %>% 
    select(id_mandato_voz, id_parlamentar_voz, id_legislatura, data_inicio, 
           data_fim, situacao, cod_causa_fim_exercicio, 
           desc_causa_fim_exercicio)
  
  return(mandatos)
}
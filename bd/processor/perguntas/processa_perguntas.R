#' @title Processa dados de perguntas
#' @description Processa os dados de perguntas e adiciona o id do tema da pergunta
#' @param perg_data_path Caminho para o arquivo de dados de perguntas sem tratamento
#' @return Dataframe com informações das perguntas incluindo o id do tema da pergunta
processa_perguntas <- function(perg_data_path = here::here("crawler/raw_data/perguntas.csv")) {
  library(tidyverse)
  library(here)
  
  perguntas <- read.csv(perg_data_path, stringsAsFactors = FALSE)
  
  perguntas_alt <- perguntas %>% 
    dplyr::mutate(tema_id = dplyr::case_when(
      tema == "Meio Ambiente" ~ 0,
      tema == "Direitos Humanos" ~ 1,
      tema == "Integridade e Transparência" ~ 2,
      tema == "Nova Economia" ~ 3,
      tema == "Transversal" ~ 4,
      TRUE ~ 5
    )) %>% 
    dplyr::select(texto, id, tema_id)
  
  return(perguntas_alt)
}

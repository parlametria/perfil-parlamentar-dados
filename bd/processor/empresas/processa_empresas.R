#' @title Processa os dados sobre as empresas
#' @description Retorna um dataframe contendo informações sobre empresas no formato do BD.
#' @param parlamentares_datapath Caminho para o dataframe contendo dados de parlamentares
#' @return Dataframe com dados processados de empresas
processa_empresas <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(here)
  library(tidyverse)
  source(here("parlametria/processor/empresas/processa_empresas.R"))
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa)
  
  empresas <- process_empresas() 
  
  empresas_filtered <- empresas %>% 
    inner_join(parlamentares, 
               by = c("id_parlamentar" = "id",
                      "casa"))
  
  empresas_alt <- empresas_filtered %>% 
    mutate(casa_enum = if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa_enum, id_parlamentar)) %>% 
    select(cnpj, razao_social, id_parlamentar_voz, data_entrada_sociedade) %>% 
    distinct()
  
  return(empresas_alt)
}
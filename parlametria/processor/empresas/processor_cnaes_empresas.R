#' @title Processa os dados sobre o grupo econômico das empresas
#' @description A partir de um um dataframe contendo os números dos cnaes, faz o mapeamento para um grupo de atividade econômica.
#' @param info_empresas_datapath Caminho para o dataframe com as informações cnaes fiscais e secundários das empresas
#' @return Dataframe com nova coluna contendo o grupo de atividade econômica
process_cnaes_empresas <- function(
  info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  info_empresas <- read_csv(info_empresas_datapath, col_types = cols(.default = "c")) %>% 
    mutate(cnae_codigo_processed = str_pad(cnae_codigo, 7, pad = "0")) %>% 
    mutate(classe_cnae = substr(cnae_codigo_processed, 1, 2))
  
  grupos_cnaes <- 
    jsonlite::fromJSON(here("parlametria/processor/empresas/constants.json"))$grupos_cnae
  
  grupos_cnaes <- grupos_cnaes %>% 
    as.data.frame() %>% 
    unnest(cols = c(codigos))
  
  empresas_grupos_cnae <- left_join(info_empresas,
                                    grupos_cnaes,
                                    by = c("classe_cnae" = "codigos")) %>% 
    select(-c(classe_cnae, cnae_codigo_processed)) %>% 
    rename(grupo_atividade_economica = nome) %>% 
    distinct()
  
  return(empresas_grupos_cnae)
}
#' @title Processa os dados sobre os grupos econômicos das empresas
#' @description Gera um datafrane contendo id e grupo de atividade econômica.
#' @return Dataframe com identificador e grupo de atividade econômica.
process_atividade_economica <- function() {
  library(here)
  library(tidyverse)
  
  grupos_atividade_economica <- 
    jsonlite::fromJSON(here("parlametria/processor/empresas/constants.json"))$grupos_cnae$nome %>% 
    tibble::enframe(name = NULL) %>% 
    rename(nome = value) %>% 
    arrange(nome) %>% 
    rowid_to_column("id_atividade_economica")
  
  return(grupos_atividade_economica)
}

#' @title Processa os dados sobre as empresas
#' @description A partir do dataframe de empresas e de parlamentares sócios, retorna um dataframe contendo 
#' cnpj, razão social, identificador da atividade econômica, identificador do parlamentar sócio e 
#' data de entrada na sociedade.
#' @param info_empresas_datapath Caminho para o dataframe com as informações das empresas
#' @param parlamentares_socios_datapath Caminho para o dataframe com as informações dos parlamentares sócios de empresas.
#' @return Dataframe com dados processados de empresas
process_empresas <- function(
  info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv"),
  parlamentares_socios_datapath = here::here("parlametria/raw_data/empresas/socios_empresas_todos_parlamentares.csv")) {
  library(here)
  library(tidyverse)
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  
  empresas <- process_cnaes_empresas(info_empresas_datapath)
  parlamentares_socios <- read_csv(parlamentares_socios_datapath, col_types = cols(.default = "c")) %>% 
    mutate(casa = if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa, id_parlamentar)) %>% 
    select(id_parlamentar_voz, cnpj, data_entrada_sociedade)
  
  empresas <- empresas %>% 
    filter(cnae_tipo == 'cnae_fiscal') %>% 
    select(cnpj, razao_social, grupo_atividade_economica) %>% 
    distinct()
  
  atividade_economica <- process_atividade_economica()
  
  empresas_alt <- empresas %>% 
    left_join(atividade_economica,
              by = c("grupo_atividade_economica" = "nome")) %>% 
    select(-grupo_atividade_economica) %>% 
    left_join(parlamentares_socios,
              by = "cnpj")
  
  return(empresas_alt)

}
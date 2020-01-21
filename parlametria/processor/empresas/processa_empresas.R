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
  
  empresas <- read_csv(info_empresas_datapath, col_types = cols(cnpj = "c"))
  parlamentares_socios <- read_csv(parlamentares_socios_datapath, col_types = cols(.default = "c")) %>% 
    select(id_parlamentar, casa, cnpj, data_entrada_sociedade)
  
  empresas_alt <- empresas %>% 
    left_join(parlamentares_socios,
              by = "cnpj") %>% 
    select(cnpj, razao_social, cnae_tipo, cnae_codigo, id_parlamentar, casa, data_entrada_sociedade) %>% 
    distinct()
  
  return(empresas_alt)

}
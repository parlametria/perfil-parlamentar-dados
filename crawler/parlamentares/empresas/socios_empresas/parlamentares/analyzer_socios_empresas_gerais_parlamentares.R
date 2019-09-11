#' @title Processa os dados de parlamentares que são sócios de empresas - sem filtrar pela classe do CNAE
#' @description A partir de um dataframe com todas as informações dos parlamentares sócios de empresas,
#' processamos esses dados e classificamos a empresa como exportadora ou não
#' @param empresas_parlamentares_datapath Caminho para o dataframe de empresas_parlamentares
#' @return Dataframe com informações processadas e se a empresa é exportadora ou não.
#' @example process_empresas_parlamentares()
processa_empresas_parlamentares <- function(
  empresas_parlamentares_datapath = here::here("crawler/raw_data/empresas_parlamentares.csv")) {
  
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/process_empresas_exportadoras.R"))
  
  empresas_parlamentares <- read_csv(empresas_parlamentares_datapath) %>% 
    select(id_deputado = id,
           cnpj,
           nome_socio,
           cnpj_cpf_do_socio,
           percentual_capital_social,
           data_entrada_sociedade) %>% 
  classifica_empresas_exportacao()  
  
  return(empresas_parlamentares)

}
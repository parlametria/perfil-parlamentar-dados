#' @title Processa os dados de parlamentares que receberam doações de sócios de empresas
#' sem filtrar pela classe do CNAE
#' @description A partir de um dataframe com todas as informações dos parlamentares que 
#' receberam doações de sócios de empresas, processamos esses dados e classificamos a 
#' empresa como exportadora ou não
#' @param empresas_doadores_datapath Caminho para o dataframe de empresas_doadores
#' @return Dataframe com informações processadas e se a empresa é exportadora ou não.
#' @example processa_socios_empresas_doadores()
processa_socios_empresas_doadores <- function(
  empresas_doadores_datapath = here::here("crawler/raw_data/empresas_doadores.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
  empresas_info_datapath = NULL) {
  
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/process_empresas_exportadoras.R"))
  
  empresas_doadores <- read_csv(empresas_doadores_datapath) %>% 
    select(id_deputado,
           cnpj = cnpj_empresa,
           nome_socio,
           cpf_cnpj_socio,
           data_entrada_sociedade,
           valor_doado) %>% 
    classifica_empresas_exportacao() 
  
  parlamentares <- read_csv(parlamentares_datapath) %>% 
    select(id, 
           nome_deputado = nome_eleitoral, 
           partido_deputado = sg_partido, 
           uf_deputado = uf)
  
  empresas_doadores_parlamentares <- empresas_doadores %>% 
    left_join(parlamentares, by = c("id_deputado" = "id"))
  
  empresas_doadores_parlamentares <- empresas_doadores_parlamentares %>% 
    select(cnpj,
           exportadora,
           cpf_cnpj_socio,
           nome_socio,
           data_entrada_sociedade,
           id_deputado,
           nome_deputado,
           partido_deputado,
           uf_deputado,
           valor_doado)
  
  if (is.null(empresas_info_datapath)) {
    cnpjs <- empresas_doadores %>% distinct(cnpj) 
    source(here::here("crawler/parlamentares/empresas/fetcher_empresas.R"))
    
    empresas_info <- purrr::map_df(cnpjs$cnpj, ~ fetch_dados_empresa_por_cnpj(.x))
  } else {
    empresas_info <- read_csv(empresas_info_datapath,
                              col_types = cols(.default = "c"))
  }
  
  empresas_doadores_parlamentares_res <- empresas_doadores_parlamentares %>% 
    left_join(empresas_info, by = "cnpj")
  
  return(empresas_doadores_parlamentares_res)
  
}

#' @title Processa os dados de parlamentares que receberam doações de empresas
#' sem filtrar pela classe do CNAE
#' @description A partir de um dataframe com todas as informações dos parlamentares que 
#' receberam doações de empresas, processamos esses dados e classificamos a 
#' empresa como exportadora ou não
#' @param empresas_doadores_datapath Caminho para o dataframe de empresas_doadores
#' @return Dataframe com informações processadas e se a empresa é exportadora ou não.
#' @example processa_empresas_doadores()
processa_empresas_doadores <- function(
  empresas_doadores_datapath = here::here("crawler/raw_data/somente_empresas_gerais_2014.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
  empresas_info_datapath = NULL) {
  
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/process_empresas_exportadoras.R"))
  
  empresas_doadores <- read_csv(empresas_doadores_datapath) %>% 
    select(cnpj = cnpj_empresa,
           id_deputado,
           valor_doado) %>% 
    classifica_empresas_exportacao() %>% 
    distinct()
  
  parlamentares <- read_csv(parlamentares_datapath) %>% 
    select(id, 
           nome_deputado = nome_eleitoral, 
           partido_deputado = sg_partido, 
           uf_deputado = uf)
  
  empresas_doadores_parlamentares <- empresas_doadores %>% 
    left_join(parlamentares, by = c("id_deputado" = "id"))
  
  
  if (is.null(empresas_info_datapath)) {
    cnpjs <- empresas_doadores %>% distinct(cnpj) 
    source(here::here("crawler/parlamentares/empresas/fetcher_empresas.R"))
    
    empresas_info <- purrr::map_df(cnpjs$cnpj, ~ fetch_dados_empresa_por_cnpj(.x))
  } else {
    empresas_info <- read_csv(empresas_info_datapath,
                              col_types = cols(.default = "c"))
  }
  
  empresas_doadores_parlamentares_res <- empresas_doadores_parlamentares %>% 
    left_join(empresas_info, by = "cnpj")
  
  return(empresas_doadores_parlamentares_res)
  
}
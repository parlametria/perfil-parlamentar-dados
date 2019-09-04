#' @title Processa dados dos sócios de empresas agrícolas que doaram em campanhas eleitorais
#' @description A partir de um um dataframe contendo cnpj das empresas e os doadores de campanha, 
#' recupera os que são sócios de empresas agrícolas.
#' @param empresas_doadores Dataframe com as informações dos doadores que são sócios em empresas
#' @return Dataframe com informações dos sócios de empresas agrícolas
fetch_socios_empresas_agricolas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/empresas_doadores.csv"))) {
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/fetcher_empresas.R"))
  
  empresas_socios_agricolas <- 
    fetch_empresas_agricolas(empresas_doadores)
  
  empresas_socios_agricolas <- empresas_socios_agricolas %>% 
    select(id_deputado = id, 
           cnpj, 
           nome_socio, 
           cnpj_cpf_do_socio, 
           percentual_capital_social, 
           data_entrada_sociedade)
  
  return(empresas_socios_agricolas)
}

#' @title Processa dados das empresas agrícolas que doaram em campanhas eleitorais
#' @description A partir de um um dataframe contendo cnpj das empresas doadoras de campanha, 
#' recupera os dados das empresas agrícolas.
#' @param empresas_doadores Dataframe com as informações dos doadores 
#' @return Dataframe com informações das empresas agrícolas
fetch_empresas_rurais_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/empresas_doadores.csv"))) {
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/fetcher_empresas.R"))
  
  empresas_socios_agricolas <- 
    fetch_empresas_agricolas(empresas_doadores)
  
  return(empresas_socios_agricolas)
}
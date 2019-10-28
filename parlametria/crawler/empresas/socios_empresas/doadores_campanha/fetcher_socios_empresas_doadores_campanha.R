#' @title Processa dados dos sócios de empresas que doaram em campanhas eleitorais
#' @description A partir de um um dataframe contendo cnpj das empresas e os doadores de campanha, 
#' recupera os que são sócios de empresas.
#' @param empresas_doadores Dataframe com as informações dos doadores que são sócios em empresas
#' @param somente_empresas Flag para indicar a filtragem de empresas agrícolas ou todas as empresas.
#' @return Dataframe com informações dos sócios de empresas
fetch_socios_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("parlametria/raw_data/empresas/empresas_doadores.csv")),
  somente_agricolas = FALSE) {
  library(tidyverse)
  
  source(here::here("parlametria/crawler/empresas/fetcher_empresas.R"))
  
  empresas_socios <- fetch_empresas(empresas_doadores, somente_agricolas)

  empresas_socios <- empresas_socios %>% 
    select(id_parlamentar = id, 
           casa,
           cnpj, 
           nome_socio, 
           cnpj_cpf_do_socio, 
           percentual_capital_social, 
           data_entrada_sociedade)
  
  return(empresas_socios)
}

#' @title Processa dados das empresas agrícolas que doaram em campanhas eleitorais
#' @description A partir de um um dataframe contendo cnpj das empresas doadoras de campanha, 
#' recupera os dados das empresas agrícolas.
#' @param empresas_doadores Dataframe com as informações dos doadores 
#' @return Dataframe com informações das empresas agrícolas
fetch_empresas_rurais_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("parlametria/raw_data/empresas/empresas_doadores.csv"))) {
  library(tidyverse)
  
  source(here::here("parlametria/crawler/empresas/fetcher_empresas.R"))
  
  empresas_socios_agricolas <- 
    fetch_empresas(empresas_doadores, TRUE)
  
  return(empresas_socios_agricolas)
}
#' @title Processa dados das empresas agrícolas a partir do dataframe dos sócios que são parlamentares em exercício
#' @description A partir de um um dataframe contendo cnpj das empresas e os sócios,
#' filtra as que são agrícolas e adiciona novas informações
#' @param empresas_deputados Dataframe com as informações dos parlamentares sócios em empresas
#' @return Dataframe com informações dos sócios e das empresas agrícolas
fetch_socios_empresas_agricolas_parlamentares <- function(
  empresas_deputados = here::here("crawler/raw_data/empresas_parlamentares.csv")) {
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/empresas/fetch_empresas.R"))
  
  empresas_socios_agricolas <- 
    fetch_empresas_agricolas(empresas_deputados)
  
  empresas_socios_agricolas <- empresas_socios_agricolas %>% 
    select(id_deputado = id, 
           cnpj, 
           nome_socio, 
           cnpj_cpf_do_socio, 
           percentual_capital_social, 
           data_entrada_sociedade)
  
  return(empresas_socios_agricolas)
}
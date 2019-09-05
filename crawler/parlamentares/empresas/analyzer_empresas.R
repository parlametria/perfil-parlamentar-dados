#' @title Processa os dados das empresas e sócios 
#' @description A partir do dataframe de doadores e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações dos sócios de empresas agrícolas
#' @param ano_eleicao Ano da eleição de interesse
#' @param tipo Tipo do sócio: "parlamentares" ou "doadores"
#' @return Dataframe com mais dados sobre os sócios e as empresas agrícolas
process_socios_empresas_agricolas <- function(ano_eleicao = 2018, tipo = "parlamentares") {
  library(tidyverse)
  library(here)
  
  socios_empresas_agricolas <- tribble()
  
  if(tolower(tipo) == "parlamentares") {
    source(here("crawler/parlamentares/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_parlamentares.R"))
    socios_empresas_agricolas <- process_socios_empresas_agricolas_parlamentares()
  } else {
    source(here("crawler/parlamentares/empresas/socios_empresas/doadores_campanha/analyzer_socios_empresas_doadores_campanha.R"))
    socios_empresas_agricolas <- process_socios_empresas_agricolas_doadores(ano_eleicao)
  }
  
  return(socios_empresas_agricolas)
}
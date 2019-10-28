#' @title Filtra as empresas que possuem sócios com os mesmos nomes dos doadores
#' @description Recebe um conjunto de dados de sócios de empresas e dos doadores e filtra as empresas
#' que possuem sócios com os mesmos nomes dos doadores
#' @param doadores_folderpath Caminho para o dataframe com dados de doadores de campanhas
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes dos doadores
filter_empresas_agricolas_doadoras <- function(
  doadores_folderpath = here::here("parlametria/raw_data/receitas/deputados_doadores.csv")) {
  library(tidyverse)
  
  empresas_doadoras <- read_csv(doadores_folderpath) %>% 
    filter(nchar(cpf_cnpj_doador) > 11) %>% 
    select(id, cpf_cnpj_doador, nome_doador, origem_receita, valor_receita) 
  
  return(empresas_doadoras)
}

#' @title Processa os dados das empresas e sócios doadores de campanha
#' @description A partir do dataframe de doadores e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações das empresas agrícolas dos sócios, ou uma lista 
#' adicionada do dataframe das próprias empresas doadoras, até as eleições de 2014.
#' @param ano Ano da eleição de interesse
#' @param doadores_folderpath Caminho para o dataframe das doações para a campanha dos parlamentares
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @param fragmentado Flag que indica se o processamento deve ser fragmentado ou não. Indicado para computadores com
#' poder computacional limitado (menos de 12 GB de memória RAM)
#' @return Dataframe com mais dados sobre os sócios, as empresas, os deputados e as doações recebidas
#' @example process_socios_empresas_agricolas_por_receita()
process_socios_empresas_agricolas_doadores <- function(
  ano = 2018,
  doadores_folderpath = here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv"),
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz"),
  fragmentado = TRUE) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/fetcher_socios_empresas_doadores_campanha.R"))
  source(here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/analyzer_socios_empresas_doadores_campanha.R"))
  
  socios_empresas_doadores <-
    filter_socios_empresas_doadores(socios_folderpath, doadores_folderpath)
  
  if (isTRUE(fragmentado)) {
    source(here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/paraleliza_fetcher_socios_empresas_doadores_campanha.R"))
    socios_empresas_agricolas <- process_socios_empresas_fragmentado(socios_empresas_doadores, TRUE)
  
  } else {
    socios_empresas_agricolas <- fetch_socios_empresas_doadores(socios_empresas_doadores, TRUE)
  }
  
  socios_empresas_agricolas <- socios_empresas_agricolas %>% 
    mutate(id_parlamentar = as.character(id_parlamentar))
  
  res_socios <- process_socios_empresas_doadores(socios_empresas_agricolas, ano)
  
  if(ano >= 2018) {
    return(list(res_socios))
  }
  
  empresas_doadoras <- filter_empresas_agricolas_doadoras(doadores_folderpath) %>% 
    rename(cnpj = cpf_cnpj_doador)
  
  empresas_agricolas <- fetch_empresas_rurais_doadores(empresas_doadoras)
  
  empresas_agricolas <- empresas_agricolas %>% 
    mutate(id = as.character(id))
  
  res_empresas <- process_empresas_doadores(empresas_agricolas, ano)
  
  return(list(res_socios, res_empresas))
  
}
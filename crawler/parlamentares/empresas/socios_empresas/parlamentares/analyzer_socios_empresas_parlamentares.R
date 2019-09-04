#' @title Filtra as empresas que possuem sócios com os mesmos nomes e 6 dígitos do 
#' cpf/cnpj dos parlamentares em exercício
#' @description Recebe um conjunto de dados de sócios de empresas e dos parlamentares e filtra as empresas
#' que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos parlamentares em exercício
#' @param socios_folderpath Caminho para a pasta que contém o csv sobre as empresas e 
#' seus sócios, cadastrados na Receita Federal
#' @param doadores_folderpath Caminho para o dataframe com dados de parlamentares
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpg/cnpj dos parlamentares
filter_socios_empresas_parlamentares <- function(
  socios_folderpath = here::here("crawler/raw_data/socio.csv.gz"),
  parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  library(here)
  
  source(here("crawler/utils/utils.R"))
  
  socio <- read_csv(socios_folderpath, col_types = "cccccccccc")
  
  socio <- socio %>% 
    filter(!is.na(cnpj_cpf_do_socio)) %>% 
    mutate(cnpj_cpf_do_socio = gsub("\\*", "", cnpj_cpf_do_socio),
           nome_socio = padroniza_nome(nome_socio))
  
  parlamentares <- read_csv(parlamentares_folderpath) %>% 
    filter(casa == 'camara', em_exercicio == 1) %>% 
    select(id, nome_civil, cpf) %>% 
    mutate(nome_civil = padroniza_nome(nome_civil),
           cpf = substring(cpf, 4, 9))
  
  
  empresas_deputados <- socio %>% 
    inner_join(parlamentares, 
               by=c("nome_socio"="nome_civil",
                    "cnpj_cpf_do_socio" = "cpf"))
  
  return(empresas_deputados)
}

#' @title Filtra as empresas que possuem sócios com os mesmos nomes dos doadores
#' @description Recebe um conjunto de dados de sócios de empresas e dos doadores e filtra as empresas
#' que possuem sócios com os mesmos nomes dos doadores
#' @param doadores_folderpath Caminho para o dataframe com dados de doadores de campanhas
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes dos doadores
filter_empresas_agricolas_doadoras <- function(
  doadores_folderpath = here::here("crawler/raw_data/deputados_doadores.csv")) {
  library(tidyverse)
  
  empresas_doadoras <- read_csv(doadores_folderpath) %>% 
    filter(nchar(cpf_cnpj_doador) > 11) %>% 
    select(id, cpf_cnpj_doador, nome_doador, origem_receita, valor_receita) 
  
  return(empresas_doadoras)
}

#' @title Processa os dados das empresas e sócios que são parlamentares
#' @description A partir do dataframe de parlamentares e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações das empresas agrícolas dos sócios.
#' @param ano Ano da eleição de interesse
#' @param parlamentares_folderpath Caminho para o dataframe dos parlamentares
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @return Dataframe com mais dados sobre os sócios, as empresas, e os deputados
process_socios_empresas_agricolas_parlamentares <- function(
  parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv"),
  socios_folderpath = here::here("crawler/raw_data/socio.csv.zip")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/empresas/socios_empresas/parlamentares/fetcher_socios_empresas_parlamentares.R"))
  
  socios_empresas_parlamentares <- filter_socios_empresas_parlamentares(socios_folderpath, parlamentares_folderpath)
  
  socios_empresas_agricolas <- fetch_socios_empresas_agricolas_parlamentares(socios_empresas_parlamentares)
  
  return(list(socios_empresas_agricolas))
  
}
#' @title Filtra as empresas que possuem sócios com os mesmos nomes e 6 dígitos do 
#' cpf/cnpj dos parlamentares em exercício por casa
#' @description Recebe um conjunto de dados de sócios de empresas e dos parlamentares e filtra as empresas
#' que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos parlamentares em exercício (por casa de origem).
#' @param socios_folderpath Caminho para a pasta que contém o csv sobre as empresas e 
#' seus sócios, cadastrados na Receita Federal
#' @param doadores_folderpath Caminho para o dataframe com dados de parlamentares
#' @param casa_origem Casa de origem 
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpg/cnpj dos parlamentares por casa.
filter_socios_empresas_parlamentares_casa <- function(
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz"),
  parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv"),
  casa_origem = "camara") {
  
  library(tidyverse)
  library(here)
  
  source(here("crawler/utils/utils.R"))
  
  socio <- read_csv(socios_folderpath, col_types = "cccccccccc")
  
  socio <- socio %>% 
    filter(!is.na(cnpj_cpf_do_socio)) %>% 
    mutate(cnpj_cpf_do_socio = gsub("\\*", "", cnpj_cpf_do_socio),
           nome_socio = padroniza_nome(nome_socio))
  
  parlamentares <- read_csv(parlamentares_folderpath) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, nome_civil, cpf)
  
  if (casa_origem == "senado") {
    parlamentares <-
      process_cpf_parlamentares_senado(parlamentares)
  } else if (casa_origem != "camara") {
    stop("O parâmetro casa_origem deve ser 'camara' ou 'senado'")
  }
  
  parlamentares <- parlamentares %>% 
    mutate(nome_civil = padroniza_nome(nome_civil),
           cpf = substring(cpf, 4, 9))
  
  empresas_parlamentares <- socio %>% 
    inner_join(parlamentares, 
               by=c("nome_socio"="nome_civil",
                    "cnpj_cpf_do_socio" = "cpf")) %>% 
    mutate(casa = casa_origem)
  
  return(empresas_parlamentares)
}

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

#' @title Processa os dados das empresas e sócios que são parlamentares
#' @description A partir do dataframe de parlamentares e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações das empresas agrícolas dos sócios.
#' @param ano Ano da eleição de interesse
#' @param parlamentares_folderpath Caminho para o dataframe dos parlamentares
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @return Dataframe com mais dados sobre os sócios, as empresas, e os deputados
process_socios_empresas_agricolas_parlamentares <- function(
  parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv"),
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz")) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/fetcher_socios_empresas_parlamentares.R"))
  
  socios_empresas_parlamentares <- filter_socios_empresas_parlamentares(socios_folderpath, parlamentares_folderpath)
  
  socios_empresas_agricolas <- fetch_socios_empresas_agricolas_parlamentares(socios_empresas_parlamentares)
  
  return(list(socios_empresas_agricolas))
  
}

#' @title Recupera os cpfs dos senadores
#' @description Recebe um caminho para o dataset de candidatos e o dataset de parlamentares, e une os parlamentares com os
#' dados da eleição a fim de extrair o CPF para os senadores.
#' @param candidatos_data_path Caminho para o dataframe com dados de candidatos
#' @param parlamentares Dataframe com dados de parlamentares
#' @return Dataframe contendo id e CPF dos senadores
process_cpf_parlamentares_senado <- function(
  parlamentares = readr::read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")),
  candidatos_data_path = here::here("parlametria/raw_data/dados_tse/consulta_cand_2018_BRASIL.csv.zip")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/utils/utils.R"))
  
  candidatos <- read_delim(candidatos_data_path, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                           locale = locale(encoding = 'latin1')) %>% 
    mutate(DS_CARGO = str_to_title(DS_CARGO)) %>% 
    filter(DS_CARGO %in% c("Senador")) %>% 
    select(NM_CANDIDATO, NR_CPF_CANDIDATO)
  
  parlamentares <- parlamentares %>% 
    select(id, nome_civil)
  
  senadores_com_cpf <- parlamentares %>% 
    mutate(nome_padronizado = padroniza_nome(nome_civil)) %>% 
    inner_join(candidatos %>% 
                 mutate(nome_padronizado = padroniza_nome(NM_CANDIDATO)), 
               by = c("nome_padronizado")) %>% 
    select(id, 
           cpf = NR_CPF_CANDIDATO,
           nome_civil)
  
  return(senadores_com_cpf)
}

#' @title Filtra as empresas que possuem sócios com os mesmos nomes e 6 dígitos do 
#' cpf/cnpj dos parlamentares em exercício
#' @description Recebe um conjunto de dados de sócios de empresas e dos parlamentares e filtra as empresas
#' que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos parlamentares em exercício.
#' @param socios_folderpath Caminho para a pasta que contém o csv sobre as empresas e 
#' seus sócios, cadastrados na Receita Federal
#' @param doadores_folderpath Caminho para o dataframe com dados de parlamentares
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpg/cnpj dos parlamentares.
filter_socios_empresas_parlamentares <- function(
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz"),
  parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  socios_deputados <- 
    filter_socios_empresas_parlamentares_casa(socios_folderpath, parlamentares_folderpath, "camara")
  
  socios_senadores <- 
    filter_socios_empresas_parlamentares_casa(socios_folderpath, parlamentares_folderpath, "senado")
  
  socios_parlamentares <-
    socios_deputados %>% rbind(socios_senadores)
  
  return(socios_parlamentares)
}
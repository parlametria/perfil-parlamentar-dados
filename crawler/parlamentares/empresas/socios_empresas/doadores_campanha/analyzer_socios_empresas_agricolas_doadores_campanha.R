#' @title Filtra as empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos doadores
#' @description Recebe um conjunto de dados de sócios de empresas e dos doadores e filtra as empresas
#' que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos doadores
#' @param socios_folderpath Caminho para a pasta que contém o csv sobre as empresas e 
#' seus sócios, cadastrados na Receita Federal
#' @param doadores_folderpath Caminho para o dataframe com dados de doadores de campanhas
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpg/cnpj dos doadores
filter_socios_empresas_doadores <- function(
  socios_folderpath = here::here("crawler/raw_data/socio.csv.gz"),
  doadores_folderpath = here::here("crawler/raw_data/deputados_doadores.csv")) {
  
  library(tidyverse)
  
  source(here::here("crawler/utils/utils.R"))
  
  socio <- read_csv(socios_folderpath, col_types = "cccccccccc")
  
  socio <- socio %>% 
    filter(!is.na(cnpj_cpf_do_socio)) %>% 
    mutate(cnpj_cpf_do_socio = gsub("\\*", "", cnpj_cpf_do_socio),
           nome_socio = padroniza_nome(nome_socio))
  
  doadores <- read_csv(doadores_folderpath) %>% 
    select(id, cpf_cnpj_doador, nome_doador, origem_receita, valor_receita) %>% 
    mutate(nome_doador = padroniza_nome(nome_doador),
           cpf_cnpj_doador_processed = substring(cpf_cnpj_doador, 4, 9))
  
  
  empresas_doadoras <- socio %>% 
    inner_join(doadores, 
               by=c("nome_socio"="nome_doador",
                    "cnpj_cpf_do_socio" = "cpf_cnpj_doador_processed"))
  
  return(empresas_doadoras)
}

#' @title Adiciona dados sobre os deputados, valor doado e se a empresa é exportadora
#' @description A partir de um dataframe de empresas com socios doadores de campanha, adiciona
#' novas informações.
#' @param empresas_doadores Dataframe de empresas agricolas cujos
#' socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
process_socios_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/empresas_doadores_agricolas_raw.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2018) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))
  source(here("crawler/parlamentares/empresas/process_empresas_exportadoras.R"))
  
  parlamentares_doacoes <- processa_doacoes_deputados_tse(ano) %>% 
    filter(casa == "camara") %>% 
    select(id, 
           nome_deputado = nome_eleitoral, 
           partido_deputado = sg_partido, 
           uf_deputado = uf, 
           valor_doado = valor_receita,
           cpf_cnpj_doador,
           nome_doador) %>% 
    mutate(id = as.character(id),
           cpf_cnpj_doador = as.character(cpf_cnpj_doador))
  
  empresas_doadores_com_nome_deputado <- empresas_doadores %>% 
    left_join(parlamentares_doacoes, by = c("id_deputado" = "id", "nome_socio" = "nome_doador")) %>% 
    rename(cpf_cnpj_socio = cpf_cnpj_doador)
  
  res <- classifica_empresas_exportacao(empresas_doadores_com_nome_deputado)
  
  res <- res %>% 
    select(cnpj_empresa = cnpj,
           exportadora,
           cpf_cnpj_socio,
           nome_socio,
           data_entrada_sociedade, 
           id_deputado,
           nome_deputado,
           partido_deputado,
           uf_deputado,
           valor_doado)
  
  return(res)
  
}

#' @title Adiciona dados sobre os deputados, valor doado e se a empresa é exportadora
#' @description A partir de um dataframe de empresas com socios doadores de campanha, adiciona
#' novas informações.
#' @param empresas_agricolas_doadores Dataframe de empresas agricolas cujos socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
#' @example process_socios_empresas_doadores()
process_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/somente_empresas_rurais_2014.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2014) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))
  source(here("crawler/parlamentares/empresas/fetcher_empresas.R"))
  
  parlamentares_doacoes <- processa_doacoes_deputados_tse(ano) %>% 
    filter(casa == "camara") %>% 
    select(id, 
           nome_deputado = nome_eleitoral, 
           partido_deputado = sg_partido, 
           uf_deputado = uf, 
           valor_doado = valor_receita,
           cpf_cnpj_doador,
           nome_doador) %>% 
    mutate(id = as.character(id),
           cpf_cnpj_doador = as.character(cpf_cnpj_doador))
  
  empresas_doadores_com_nome_deputado <- empresas_doadores %>% 
    left_join(parlamentares_doacoes, by = c("id", "nome_doador")) %>% 
    rename(cpf_cnpj_socio = cpf_cnpj_doador)
  
  res <- classifica_empresas_exportacao(empresas_doadores_com_nome_deputado)
  
  res <- res %>% 
    select(cnpj_empresa = cnpj,
           exportadora,
           cpf_cnpj_socio,
           nome_empresa = nome_doador,
           id_deputado = id,
           nome_deputado,
           partido_deputado,
           uf_deputado,
           valor_doado)
  
  return(res)
  
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

#' @title Processa os dados das empresas e sócios doadores de campanha
#' @description A partir do dataframe de doadores e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações das empresas agrícolas dos sócios, ou uma lista 
#' adicionada do dataframe das próprias empresas doadoras, até as eleições de 2014.
#' @param ano Ano da eleição de interesse
#' @param doadores_folderpath Caminho para o dataframe das doações para a campanha dos deputados
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @return Dataframe com mais dados sobre os sócios, as empresas, os deputados e as doações recebidas
#' @example process_socios_empresas_agricolas_por_receita()
process_socios_empresas_agricolas_doadores <- function(
  ano = 2018,
  doadores_folderpath = here::here("crawler/raw_data/deputados_doadores.csv"),
  socios_folderpath = here::here("crawler/raw_data/socio.csv.gz")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/empresas/socios_empresas/doadores_campanha/fetcher_socios_empresas_doadores_campanha.R"))
  
  socios_empresas_doadores <- filter_socios_empresas_doadores(socios_folderpath, doadores_folderpath)
  
  socios_empresas_agricolas <- fetch_socios_empresas_agricolas_doadores(socios_empresas_doadores)
  
  socios_empresas_agricolas <- socios_empresas_agricolas %>% 
    mutate(id_deputado = as.character(id_deputado))
  
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
#' @title Processa os dados de parlamentares que receberam doações de sócios de empresas
#' sem filtrar pela classe do CNAE
#' @description A partir de um dataframe com todas as informações dos parlamentares que 
#' receberam doações de sócios de empresas, processamos esses dados e classificamos a 
#' empresa como exportadora ou não
#' @param socios_empresas_doadores Caminho para o dataframe de empresas_doadores
#' @return Dataframe com informações processadas e se a empresa é exportadora ou não.
#' @example processa_socios_empresas_doadores()
processa_socios_empresas_doadores <- function(
  socios_empresas_doadores,
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  source(here::here("parlametria/crawler/empresas/process_empresas_exportadoras.R"))
  source(here::here("parlametria/crawler/empresas/fetcher_empresas.R"))
  
  empresas_doadores <- fetch_empresas(socios_empresas_doadores)
  
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
           id_parlamentar,
           nome_parlamentar,
           partido_parlamentar,
           uf_parlamentar,
           valor_doado)
  

  cnpjs <- empresas_doadores %>% 
    distinct(cnpj) 

  empresas_info <- purrr::map_df(cnpjs$cnpj, ~ fetch_dados_empresa_por_cnpj(.x))
  
  return(list(empresas_doadores, empresas_info))
  
}

#' @title Adiciona dados sobre os deputados, valor doado e se a empresa é exportadora
#' @description A partir de um dataframe de empresas com socios doadores de campanha, adiciona
#' novas informações.
#' @param empresas_agricolas_doadores Dataframe de empresas agricolas cujos socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
#' @example process_socios_empresas_doadores()
process_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("parlametria/raw_data/empresas/somente_empresas_agricolas_2014.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2014) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/receitas/analyzer_receitas_tse.R"))
  source(here("parlametria/crawler/empresas/fetcher_empresas.R"))
  
  parlamentares_doacoes <- processa_doacoes_parlamentares_tse(ano) %>% 
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

#' @title Processa os dados de parlamentares que receberam doações de empresas
#' sem filtrar pela classe do CNAE
#' @description A partir de um dataframe com todas as informações dos parlamentares que 
#' receberam doações de empresas, processamos esses dados e classificamos a 
#' empresa como exportadora ou não
#' @param doadores_folderpath Caminho para o dataframe das doações para a campanha dos parlamentares
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @param ano Ano de interesse
#' @param fragmentado Flag que indica se o processamento deve ser fragmentado ou não. Indicado para computadores com
#' poder computacional limitado (menos de 12 GB de memória RAM)
#' @return Lista de dataframes com informações processadas dos sócios e das respectivas empresas.
#' @example processa_empresas_doadores()
processa_empresas_doadores <- function(
  doadores_folderpath = here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv"),
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz"),
  ano = 2018,
  fragmentado = TRUE) {
  library(tidyverse)
  source(here::here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/fetcher_socios_empresas_doadores_campanha.R"))
  source(here::here("parlametria/crawler/empresas/fetcher_empresas.R"))
  
  socios_empresas_doadores <-
    filter_socios_empresas_doadores(socios_folderpath, doadores_folderpath)
  
  if (isTRUE(fragmentado)) {
    source(here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/paraleliza_fetcher_socios_empresas_doadores_campanha.R"))
    empresas_doadores <- process_socios_empresas_fragmentado(socios_empresas_doadores, FALSE)
  } else {
    empresas_doadores <- fetch_socios_empresas_doadores(socios_empresas_doadores, FALSE)
  }
  
  empresas_doadores <- empresas_doadores %>% 
    mutate(id_parlamentar = as.character(id_parlamentar))
  
  res_socios <- process_socios_empresas_doadores(empresas_doadores, ano)
  
  cnpjs <- res_socios %>% distinct(cnpj_empresa) 
  
  empresas_info <- purrr::map_df(cnpjs$cnpj_empresa, ~ fetch_dados_empresa_por_cnpj(.x))
  
  empresas_info <- empresas_info %>% 
    distinct()
  
  return(list(res_socios, empresas_info))
  
}

#' @title Filtra as empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos doadores
#' @description Recebe um conjunto de dados de sócios de empresas e dos doadores e filtra as empresas
#' que possuem sócios com os mesmos nomes e 6 dígitos do cpf/cnpj dos doadores
#' @param socios_folderpath Caminho para a pasta que contém o csv sobre as empresas e 
#' seus sócios, cadastrados na Receita Federal
#' @param doadores_folderpath Caminho para o dataframe com dados de doadores de campanhas
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e 6 dígitos do cpg/cnpj dos doadores
filter_socios_empresas_doadores <- function(
  socios_folderpath = here::here("parlametria/raw_data/empresas/socio.csv.gz"),
  doadores_folderpath = here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv")) {
  
  library(tidyverse)
  
  source(here::here("crawler/utils/utils.R"))
  
  socio <- read_csv(socios_folderpath, col_types = "cccccccccc")
  
  socio <- socio %>% 
    filter(!is.na(cnpj_cpf_do_socio)) %>% 
    mutate(cnpj_cpf_do_socio = gsub("\\*", "", cnpj_cpf_do_socio),
           nome_socio = padroniza_nome(nome_socio))
  
  doadores <- read_csv(doadores_folderpath) %>% 
    select(id, casa, cpf_cnpj_doador, nome_doador, origem_receita, valor_receita) %>% 
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
  empresas_doadores = readr::read_csv(here::here("parlametria/raw_data/empresas/empresas_doadores_agricolas_raw.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2018) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/receitas/analyzer_receitas_tse.R"))
  source(here("parlametria/crawler/empresas/process_empresas_exportadoras.R"))
  
  parlamentares_doacoes <- processa_doacoes_parlamentares_tse(ano) %>% 
    select(id, 
           casa_parlamentar = casa,
           nome_parlamentar = nome_eleitoral, 
           partido_parlamentar = sg_partido, 
           uf_parlamentar = uf, 
           valor_doado = valor_receita,
           cpf_cnpj_doador,
           nome_doador) %>% 
    mutate(id = as.character(id),
           cpf_cnpj_doador = as.character(cpf_cnpj_doador))
  
  empresas_doadores_com_nome_parlamentar <- empresas_doadores %>% 
    left_join(parlamentares_doacoes, by = c("id_parlamentar" = "id", "nome_socio" = "nome_doador")) %>% 
    rename(cpf_cnpj_socio = cpf_cnpj_doador) %>% 
    filter(!is.na(nome_parlamentar))
  
  res <- classifica_empresas_exportacao(empresas_doadores_com_nome_parlamentar)
  
  res <- res %>% 
    select(cnpj_empresa = cnpj,
           exportadora,
           cpf_cnpj_socio,
           nome_socio,
           data_entrada_sociedade, 
           id_parlamentar,
           casa_parlamentar,
           nome_parlamentar,
           partido_parlamentar,
           uf_parlamentar,
           valor_doado) %>% 
    distinct()
  
  return(res)
  
}
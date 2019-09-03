#' @title Adiciona dados sobre os deputados, valor doado e se a empresa é exportadora
#' @description A partir de um dataframe de empresas com socios doadores de campanha, adiciona
#' novas informações.
#' @param empresas_agricolas_doadores_datapath Caminho para o dataframe de empresas agricolas cujos
#' socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
#' @example process_socios_empresas_doadores()
process_socios_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/empresas_doadores_agricolas_raw.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2018) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))
  source(here("crawler/parlamentares/empresas/fetch_empresas.R"))
  
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
#' @param empresas_agricolas_doadores_datapath Caminho para o dataframe de empresas agricolas cujos
#' socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
#' @example process_socios_empresas_doadores()
process_empresas_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/somente_empresas_rurais_2014.csv"),
                                      col_types = readr::cols(.default = "c")),
  ano = 2014) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))
  source(here("crawler/parlamentares/empresas/fetch_empresas.R"))
  
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

#' @title Processa os dados das empresas e sócios doadores de campanha
#' @description A partir do dataframe de doadores e do arquivo com todos os sócios existentes nos cnpjs cadastrados
#' na Receita Federal, retorna um dataframe com as informações das empresas agrícolas dos sócios, ou uma lista 
#' adicionada do dataframe das próprias empresas doadoras, até as eleições de 2014.
#' @param doadores_folderpath Caminho para o dataframe das doações para a campanha dos deputados
#' @param socios_folderpath Caminho para o dataframe dos sócios cadastrados na Receita Federal
#' @param ano Ano da eleição de interesse
#' @return Dataframe com mais dados sobre os sócios, as empresas, os deputados e as doações recebidas
#' @example process_socios_empresas_agricolas_por_receita()
process_socios_empresas_agricolas_por_receita <- function(
  doadores_folderpath = here::here("crawler/raw_data/deputados_doadores.csv"),
  socios_folderpath = here::here("crawler/raw_data/socio.csv.zip"),
  ano = 2018) {
  
  source(here::here("crawler/parlamentares/empresas/fetch_empresas.R"))
  
  library(tidyverse)
  
  socios_empresas_doadoras <- filter_socios_empresas_doadoras(socios_folderpath, doadores_folderpath)
  
  socios_empresas_rurais <- fetch_socios_empresas_rurais_doadores(socios_empresas_doadoras)
 
  res_socios <- process_socios_empresas_doadores(socios_empresas_rurais, ano)
  
  if(ano == 2018) {
    return(res_socios)
  }
  
  empresas_doadoras <- filter_empresas_doadoras(doadores_folderpath) %>% 
    rename(cnpj = cpf_cnpj_doador)
  
  empresas_rurais <- fetch_empresas_rurais_doadores(empresas_doadoras)
  
  res_empresas <- process_empresas_doadores(empresas_rurais, ano)
  
  return(list(res_socios, res_empresas))
  
}

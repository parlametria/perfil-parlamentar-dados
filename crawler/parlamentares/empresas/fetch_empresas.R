#' @title Padroniza os nomes, retirando acentos, cedilhas e colcoando todas as letras em uppercase
#' @description Recebe um nome e o padroniza no formato: sem acentos, cedilhas, letras maiúsculas
#' @param nome Nome a ser padronizado
#' @return Nome padronizado
#' @examples
#' padroniza_nome("çíço do álcórdéón")
padroniza_nome <- function(nome) {
  library(tidyverse)
  
  return(nome %>% 
           iconv(to="ASCII//TRANSLIT") %>% 
           toupper())
}

#' @title Filtra as empresas que possuem sócios com os mesmos nomes e parte do cpf dos parlamentares
#' @description Recebe um conjunto de dados de sócios de empresas e dos parlamentares e filtra as empresas
#' que possuem sócios com os mesmos nomes e parte do cpf dos parlamentares
#' @param socios_folderpath Caminho para a pasta que contém arquivos csv sobre as empresas e seus sócios
#' @param parlamentares_folderpath Caminho para o dataframe com dados de parlamentares
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes e parte do cpf dos parlamentares
filter_empresas_parlamentares <- function(socios_folderpath = here::here("crawler/raw_data/socio.csv.zip"),
                               parlamentares_folderpath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)

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
#' @param socios_folderpath Caminho para a pasta que contém arquivos csv sobre as empresas e seus sócios
#' @param doadores_folderpath Caminho para o dataframe com dados de doadores de campanhas
#' @return Dataframe das empresas que possuem sócios com os mesmos nomes dos doadores
filter_empresas_doadoras <- function(socios_folderpath = here::here("crawler/raw_data/socio.csv.zip"),
                                      doadores_folderpath = here::here("crawler/raw_data/deputados_doadores.csv")) {
  library(tidyverse)
  
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

#' @title Retorna dados da empresa e seus CNAEs cadastrados na Receita Federal
#' @description Recebe um CNPJ e retorna os dados da empresa
#' @param cnpj CNPJ da empresa
#' @return Dataframe com informações das empresas e seus CNAES. Para CNAE uma observação é criada no Dataframe
#' @example fetch_dados_empresa_por_cnpj("04515711000150")
fetch_dados_empresa_por_cnpj <- function(cnpj) {
  library(tidyverse)
  library(httr)
  
  print(paste0("Baixando dados para o CNPJ ", cnpj))
  
  data <- list(
    cnpj = cnpj
  )
  
  url_api <- "http://localhost:8000/"
  
  json <- POST(url_api, body = data, encode = "form", verbose()) %>% 
    content(as = "parsed") 
  
  empresa <- tibble(
    cnpj = json$cnpj,
    razao_social = json$razao_social,
    capital_social = json$capital_social,
    uf = json$uf
  )
  
  if (!is.null(json$cnaes_secundarios)) {
    cnaes_secundarios <- json$cnaes_secundarios %>% 
      map(function(x) {
        cnae_sec <- tibble(cnae_tipo = "cnae_secundario",
                           cnae_codigo = x$cnae_codigo,
                           cnae_descricao = x$cnae_descricao)
        return(cnae_sec)
      }) %>% 
      reduce(rbind) %>% 
      distinct()
  } else {
    cnaes_secundarios <- tribble(~ cnae_tipo, ~ cnae_codigo, ~ cnae_descricao)
  }
  
  empresa_cnaes <- tibble(
    cnae_tipo = "cnae_fiscal",
    cnae_codigo = json$cnae_fiscal,
    cnae_descricao = ""
  ) %>%
    rbind(cnaes_secundarios) %>% 
    mutate(cnpj = cnpj) %>% 
    left_join(empresa, by = "cnpj") %>% 
    select(cnpj, razao_social, capital_social, uf, cnae_tipo, cnae_codigo, cnae_descricao)
  
  return(empresa_cnaes)
}

#' @title Processa dados das empresas agrícolas que possuem deputados como sócios
#' @description A partir de um um dataframe contendo cnpj das empresas e os deputados sócios e
#' filtra as que são agrícolas e adiciona novas informações
#' @param empresas_deputados_datapath Caminho para o dataframe com as 
#' informações dos deputados que são sócios em empresas
#' @return Dataframe com informações dos sócios e das empresas agrícolas
#' @example process_empresas_rurais_deputados()
process_empresas_rurais_deputados <- function(
  empresas_deputados_datapath = here::here("crawler/raw_data/empresas_parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  empresas_deputados <- read_csv(empresas_deputados_datapath)
  
  lista_empresas <- empresas_deputados %>% 
    distinct(cnpj)
  
  lista_empresas_cnaes <- purrr::pmap_dfr(
    list(lista_empresas$cnpj),
    ~ fetch_dados_empresa_por_cnpj(..1)
  )
  
  lista_empresas_cnaes_agricultura <- lista_empresas_cnaes %>% 
    mutate(cnae_codigo = str_pad(cnae_codigo, 7, pad = "0")) %>% 
    mutate(classe_cnae = substr(cnae_codigo, 1, 2)) %>% 
    mutate(is_agricola = classe_cnae %in% c("01", "02", "03")) %>% 
    filter(is_agricola) %>% 
    distinct(cnpj, is_agricola)
  
  empresas_deputados_agricolas <- empresas_deputados %>% 
    left_join(lista_empresas_cnaes_agricultura, by = "cnpj") %>% 
    filter(!is.na(is_agricola)) %>% 
    select(id_deputado = id, cnpj, nome_socio, cnpj_cpf_do_socio, percentual_capital_social, data_entrada_sociedade)
  
}

#' @title Processa dados das empresas agrícolas que possuem doadores de campanha como sócios
#' @description A partir de um um dataframe contendo cnpj das empresas e os doadores de campanha sócios e
#' filtra as que são agrícolas e adiciona novas informações
#' @param empresas_doadores_datapath Caminho para o dataframe com as 
#' informações dos doadores que são sócios em empresas
#' @return Dataframe com informações dos sócios e das empresas agrícolas
#' @example process_empresas_rurais_doadores()
process_empresas_rurais_doadores <- function(
  empresas_doadores = readr::read_csv(here::here("crawler/raw_data/empresas_doadores.csv"))) {
  library(tidyverse)
  library(here)
  
  lista_empresas <- empresas_doadores %>% 
    distinct(cnpj)
  
  lista_empresas_cnaes <- purrr::pmap_dfr(
    list(lista_empresas$cnpj),
    ~ fetch_dados_empresa_por_cnpj(..1)
  )
  
  lista_empresas_cnaes_agricultura <- lista_empresas_cnaes %>% 
    mutate(cnae_codigo = str_pad(cnae_codigo, 7, pad = "0")) %>% 
    mutate(classe_cnae = substr(cnae_codigo, 1, 2)) %>% 
    mutate(is_agricola = classe_cnae %in% c("01", "02", "03")) %>% 
    filter(is_agricola) %>% 
    distinct(cnpj, is_agricola)
  
  empresas_doadores_agricolas <- empresas_doadores %>% 
    left_join(lista_empresas_cnaes_agricultura, by = "cnpj") %>% 
    filter(!is.na(is_agricola)) %>% 
    select(id_deputado = id, cnpj, nome_socio, cnpj_cpf_do_socio, percentual_capital_social, data_entrada_sociedade)
}

#' @title Classifica cnpjs como empresas exportadoras ou não usando Lista do Min. da Economia
#' @description A partir de um dataframe com um coluna cnpj retorna o mesmo dataframe com uma coluna a mais indicando
#' se o cnpj é de uma empresa exportadora ou não.
#' @param df Dataframe com pelo menos uma coluna chamada cnpj
#' @return Dataframe com informação sobre se a empresa tem cnpj ou não
#' @example classifica_empresas_exportacao()
classifica_empresas_exportacao <- function(df) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/empresas/process_empresas_exportadoras.R"))
  
  empresas_exportadoras <- process_empresas_exportadoras()
  
  lista_empresas_exportadoras <- empresas_exportadoras %>% 
    select(cnpj = CNPJ) %>% 
    distinct(cnpj) %>% 
    pull(cnpj)
  
  df <- df %>% 
    mutate(exportadora = if_else(cnpj %in% lista_empresas_exportadoras, "sim", "nao")) 
    
  return(df)
}

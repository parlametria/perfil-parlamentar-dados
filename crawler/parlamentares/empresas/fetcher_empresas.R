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
  
  #' Para levantar a api, clonar repositório e seguir os passos do README.md: 
  #' https://github.com/cuducos/minha-receita
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

#' @title Processa dados das empresas agrícolas a partir do dataframe dos sócios
#' @description A partir de um um dataframe contendo cnpj das empresas e os sócios,
#' filtra as que são agrícolas e adiciona novas informações
#' @param empresas_socios Dataframe com as informações dos sócios em empresas
#' @return Dataframe com informações dos sócios e das empresas agrícolas
fetch_empresas_agricolas <- function(
  empresas_socios = readr::read_csv(here::here("crawler/raw_data/empresas_doadores.csv"))) {
  library(tidyverse)
  library(here)
  
  lista_empresas <- empresas_socios %>% 
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
  
  empresas_doadores_agricolas <- empresas_socios %>% 
    left_join(lista_empresas_cnaes_agricultura, by = "cnpj") %>% 
    filter(!is.na(is_agricola)) %>% 
    select(-is_agricola)
  
  return(empresas_doadores_agricolas)
}
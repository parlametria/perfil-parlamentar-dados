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
    cnae_fiscal = json$cnae_fiscal,
    razao_social = json$razao_social,
    capital_social = json$capital_social,
    uf = json$uf,
    data_inicio_atividade = json$data_inicio_atividade,
    data_situacao_cadastral = json$data_situacao_cadastral,
    situacao_cadastral = json$situacao_cadastral,
    motivo_situacao_cadastral = json$motivo_situacao_cadastral
  ) %>% 
    mutate(porte = json$porte)
  
  if(!is.null(json$data_situacao_especial) & !is.null(json$situacao_especial)) {
    data_situacao_especial = json$data_situacao_especial
    situacao_especial = json$situacao_especial
  } else {
    data_situacao_especial = NA
    situacao_especial = NA
  }
    
  empresa <- empresa %>% 
    mutate(data_situacao_especial = data_situacao_especial,
           situacao_especial = situacao_especial)

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
    select(cnpj, razao_social, capital_social, uf, porte, data_inicio_atividade,
           data_situacao_especial, situacao_especial, motivo_situacao_cadastral,
           cnae_tipo, cnae_codigo, cnae_descricao)
  
  return(empresa_cnaes)
}

#' @title Processa dados das empresas ou apenas empresas agrícolas a partir do dataframe dos sócios
#' @description A partir de um um dataframe contendo cnpj das empresas e os sócios,
#' filtra as que são agrícolas caso a flage steja ativada e adiciona novas informações
#' @param empresas_socios Dataframe com as informações dos sócios em empresas
#' @param somente_agricolas Flag para indicar se o filtro de agrícolas deve ser aplicado
#' @return Dataframe com informações dos sócios e das empresas
fetch_empresas <- function(
  empresas_socios = readr::read_csv(here::here("parlametria/raw_data/empresas/empresas_doadores.csv")),
  somente_agricolas = FALSE) {
  library(tidyverse)
  library(here)
  
  lista_empresas <- empresas_socios %>% 
    distinct(cnpj)
  
  lista_empresas_cnaes <- purrr::pmap_dfr(
    list(lista_empresas$cnpj),
    ~ fetch_dados_empresa_por_cnpj(..1)
  )

  if (isTRUE(somente_agricolas)) {
    lista_empresas_cnaes_agricultura <- lista_empresas_cnaes %>% 
      mutate(cnae_codigo = str_pad(cnae_codigo, 7, pad = "0")) %>% 
      mutate(classe_cnae = substr(cnae_codigo, 1, 2)) %>% 
      mutate(is_agricola = classe_cnae %in% c("01", "02", "03")) %>% 
      filter(is_agricola) %>% 
      distinct(cnpj, is_agricola)
    
    lista_empresas_cnaes <- empresas_socios %>% 
      left_join(lista_empresas_cnaes_agricultura, by = "cnpj") %>% 
      filter(!is.na(is_agricola)) %>% 
      select(-is_agricola)
  } else {
    lista_empresas_cnaes <- empresas_socios %>% 
      left_join(lista_empresas_cnaes, by = "cnpj")
  }

  return(lista_empresas_cnaes)
}
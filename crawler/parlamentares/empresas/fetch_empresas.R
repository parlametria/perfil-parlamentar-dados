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

#' @title Retorna dados da empresa e dos sócios a partir de um CNPJ
#' @description Recebe um CNPJ e retorna os dados da empresa e seus sócios
#' @param cnpj CNPJ da empresa
#' @return Lista de dataframes com os dados da empresa e dos sócios
#' @example fetch_dados_empresa_socios_por_cnpj("04515711000150")
fetch_dados_empresa_por_cnpj <- function(cnpj) {
  library(tidyverse)
  library(httr)
  
  data <- list(
    cnpj = 19131243000197
  )
  
  res <- POST(paste0("http://localhost:8000/"), body = data, encode = "json", verbose())
  
  json <- RCurl::getURI(url) %>% 
    jsonlite::fromJSON()
  
  empresa <- tibble(
    nome = json$nome,
    nome_fantasia = json$fantasia,
    cnpj = json$cnpj,
    tipo = json$tipo,
    natureza_juridica = json$natureza_juridica,
    porte = json$porte,
    data_abertura = json$abertura,
    endereco = paste0(json$logradouro, ", ", json$numero, ", ", json$bairro),
    cep = json$cep,
    municipio = json$municipio,
    uf = json$uf,
    cod_atividade_princial = json$atividade_principal$code,
    atividade_principal = json$atividade_principal$text,
    capital_social = json$capital_social,
    cod_atividade_secundaria = (json$atividades_secundarias %>% head(1))$code,
    atividade_secundaria = (json$atividades_secundarias %>% head(1))$text,
    data_situacao = json$data_situacao,
    situacao = json$situacao,
    motivo_situacao = json$motivo_situacao
  )
  
  return(list(empresa))
}


process_empresas <- function(
  empresas_path = 
    here::here("crawler/raw_data/empresas_parlamentares_ruralistas.csv")) {
  
  library(tidyverse)
  
  empresas_parlamentares_ruralistas <- 
    read_csv(empresas_parlamentares_ruralistas_path, col_types = "ccccccccccccc") %>% 
    filter(validado == 'sim')
  
  df <- purrr::map(empresas_parlamentares_ruralistas$cnpj, ~ fetch_dados_empresa_socios_por_cnpj(.x))
}




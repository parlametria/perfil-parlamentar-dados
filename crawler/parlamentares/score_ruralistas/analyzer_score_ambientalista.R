#' @title Recupera informações dos parlamentares que possuem ou não propriedades rurais
#' @description A partir do dataframe de parlamentares com propriedades rurais e do
#' dataframe de parlamentares, retorna um dataframe que contém id, cpf e proprietario_de_terras,
#' sendo 1 quando o parlamentar tiver alguma propriedade rural e 0, caso contrário.
#' @param propriedades_rurais_datapath Caminho para o dataframe de parlamentares com propriedades
#' rurais
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e se possuem terras ou não
calcula_score_propriedades_rurais <- function(
  propriedades_rurais_datapath = here::here("crawler/raw_data/propriedades_rurais.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  propriedades_rurais <- read_csv(propriedades_rurais_datapath, col_types = cols(id_camara = "c")) %>% 
    mutate(proprietario_de_terras = 1, indice_propriedade = total_declarado / max(total_declarado)) %>% 
    select(id_camara, cpf, indice_propriedade)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf)
  
  parlamentares_propriedades_rurais <- parlamentares %>% 
    left_join(propriedades_rurais,
              by = c("cpf", "id" = "id_camara")) %>% 
    mutate(indice_propriedade = if_else(is.na(indice_propriedade), 0, indice_propriedade))
  
  return(parlamentares_propriedades_rurais)
}

#' @title Recupera informações dos parlamentares que possuem ou não empresas agrícolas
#' @description A partir do dataframe de parlamentares com empresas agrícolas e do
#' dataframe de parlamentares, retorna um dataframe que contém id, cpf e socios_empresas_rurais,
#' sendo 1 quando o parlamentar for socio de alguma empresa agrícola e 0, caso contrário.
#' @param socios_empresas_rurais_datapath Caminho para o dataframe de parlamentares sócios de
#' empresas rurais
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e se possuem empresas 
#' agrícolas ou não.
calcula_score_socios_empresas_rurais <- function(
  socios_empresas_rurais_datapath = here::here("crawler/raw_data/empresas_parlamentares_agricolas.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  socios_empresas_rurais <- read_csv( socios_empresas_rurais_datapath, col_types = cols(id_deputado = "c")) %>% 
    group_by(id_deputado) %>% 
    summarise(numero_empresas_associadas = n()) %>% 
    mutate(numero_empresas_associadas = log(numero_empresas_associadas) / log(max(numero_empresas_associadas))) %>% 
    select(id_deputado, numero_empresas_associadas)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf)
  
  parlamentares_socios_empresas_rurais <- parlamentares %>% 
    left_join(socios_empresas_rurais,
              by = c("id" = "id_deputado")) %>% 
    mutate(numero_empresas_associadas = if_else(is.na(numero_empresas_associadas), 0, as.numeric(numero_empresas_associadas)))
  
  return(parlamentares_socios_empresas_rurais)
}

#' @title Recupera informações dos parlamentares que receberam doações de empresas agrícolas
#' @description A partir do dataframe de doações de parlamentares que são empresas agrícolas 
#' ou de sócios de empresas agrícolas, e do dataframe de parlamentares, 
#' retorna um dataframe com informações do parlamentar e das doações
#' @param doadores_socios_empresas_rurais_2018_datapath Caminho para o dataframe de doações de campanha 
#' de sócios de empresas rurais em 2018
#' @param doadores_socios_empresas_rurais_2014_datapath Caminho para o dataframe de doações de campanha 
#' de sócios de empresas rurais em 2014
#' @param doadores_empresas_rurais_2014_datapath Caminho para o dataframe de doações de campanha 
#' de empresas rurais em 2014
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id), doacao_empresas_agricolas se possuem 
#' empresas ou sócios de empresas agrícolas ou não e se essas empresas são exportadoras ou não (1 ou 0, res-
#' pectivamente)
calcula_score_doacoes_empresas_rurais <- function(
  doadores_socios_empresas_rurais_2018_datapath = here::here("crawler/raw_data/empresas_doadores_agricolas.csv"),
  doadores_socios_empresas_rurais_2014_datapath = here::here("crawler/raw_data/empresas_doadores_agricolas_2014.csv"),
  doadores_empresas_rurais_2014_datapath = here::here("crawler/raw_data/somente_empresas_agricolas_2014.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  empresas_doadoras <- 
    purrr::map2_df(
      list(doadores_socios_empresas_rurais_2018_datapath,
           doadores_socios_empresas_rurais_2014_datapath,
           doadores_empresas_rurais_2014_datapath),
      list(2018, 2014, 2014),
      function(x, y) {
        read_csv(x, col_types = cols(id_deputado = "c")) %>%
          select(id_deputado, cnpj_empresa, valor_doado, exportadora) %>% 
          mutate(ano = y,
                 exportadora = if_else(exportadora == 'sim', 1, 0)) %>% 
          group_by(cnpj_empresa, ano) %>% 
          mutate(exportadora = max(exportadora)) %>% 
          distinct()
        })

  empresas_doadoras <- empresas_doadoras %>% 
    group_by(cnpj_empresa, ano) %>% 
    mutate(valor_total_doado_por_campanha = sum(valor_doado))
  
  empresas_doadoras <- empresas_doadoras %>% 
    group_by(cnpj_empresa, id_deputado, ano) %>% 
    mutate(proporcao_doacao_campanha = valor_doado / valor_total_doado_por_campanha)
  
  empresas_doadoras <- empresas_doadoras %>% 
    spread(ano, proporcao_doacao_campanha) %>% 
    rename(proporcao_doacao_campanha_2018 = `2018`,
           proporcao_doacao_campanha_2014 = `2014`) %>% 
    select(-c(valor_doado, valor_total_doado_por_campanha))
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf)
  
  parlamentares_socios_empresas_rurais <- parlamentares %>% 
    left_join(empresas_doadoras,
              by = c("id" = "id_deputado")) %>% 
    mutate(proporcao_doacao_campanha_2014 = if_else(is.na(proporcao_doacao_campanha_2014), 0, proporcao_doacao_campanha_2014),
           proporcao_doacao_campanha_2018 = if_else(is.na(proporcao_doacao_campanha_2018), 0, proporcao_doacao_campanha_2018))
  
  return(parlamentares_socios_empresas_rurais)
}
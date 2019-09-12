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
    select(id_camara, cpf, total_declarado)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf)
  
  parlamentares_propriedades_rurais <- parlamentares %>% 
    left_join(propriedades_rurais,
              by = c("cpf", "id" = "id_camara")) %>% 
    mutate(total_declarado = if_else(is.na(total_declarado), 0, total_declarado))
  
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
  doadores_gerais_2018_datapath = here::here("crawler/raw_data/deputados_doadores.csv"),
  doadores_socios_empresas_rurais_2018_datapath = here::here("crawler/raw_data/empresas_doadores_agricolas.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  doadores <- read_csv( doadores_gerais_2018_datapath, col_types = cols(id = "c"))
  
  doadores_totais <- doadores %>%
    group_by(id) %>% 
    summarise(total_doacao = sum(valor_receita)) %>% 
    select(id, total_doacao)
  
  doadores_rurais_todos <- read_csv(doadores_socios_empresas_rurais_2018_datapath, col_types = cols(id_deputado = "c")) %>% 
    group_by(cpf_cnpj_socio) %>% 
    summarise(n = n())
  
  doadores_rurais <- doadores %>% 
    left_join(doadores_rurais_todos, by = c("cpf_cnpj_doador" = "cpf_cnpj_socio")) %>% 
    filter(!is.na(n)) %>% 
    group_by(id) %>% 
    summarise(total_doacao_agro = sum(valor_receita))
  
  indice_doadores = doadores_totais %>% 
    inner_join(doadores_rurais, by = c("id")) %>% 
    mutate(proporcao_doacoes_agro = total_doacao_agro/total_doacao)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf)
  
  parlamentares_doacoes <- parlamentares %>% 
    left_join(indice_doadores, by = c("id"))
  
  return(parlamentares_doacoes)
}

#' @title Índice de Vínculo Econômico
#' @description Unifica as informações de propriedades rurais, sociedades em empresas ruraris e doações de ruralistas
#' para gerar um Índice de Vínculo Economico com o agronegócio
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (id, cpf, nome, uf e partido), valor total em propriedades rurais,
#' quantidade de empresas rurais as quais é socio e proporção de doações de empresas rurais em relação ao total doado
processa_indice_vinculo_economico <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")
) {
  propriedades_rurais <- calcula_score_propriedades_rurais()
  socios <- calcula_score_socios_empresas_rurais()
  doacoes <- calcula_score_doacoes_empresas_rurais()
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf, nome_eleitoral, uf, sg_partido)
  
  indice_vinculo_economico <- parlamentares %>% 
    left_join(propriedades_rurais, by = c("id", "cpf")) %>% 
    left_join(socios, by = c("id", "cpf")) %>% 
    left_join(doacoes, by = c("id", "cpf")) %>% 
    select(id, cpf, nome_eleitoral, uf, sg_partido, total_declarado, numero_empresas_associadas, proporcao_doacoes_agro)
  
  return(indice_vinculo_economico)
}
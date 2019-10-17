#' @title Recupera informações dos parlamentares que possuem ou não propriedades rurais
#' @description A partir do dataframe de parlamentares com propriedades rurais e do
#' dataframe de parlamentares, retorna um dataframe que contém id, cpf e o total declarado
#' no TSE em propriedades rurais.
#' @param propriedades_rurais_datapath Caminho para o dataframe de parlamentares com propriedades
#' rurais
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e total declarado no TSE
#' em propriedades rurais
calcula_score_propriedades_rurais <- function(
  propriedades_rurais_datapath = here::here("parlametria/raw_data/patrimonio/propriedades_rurais.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  library(here)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  propriedades_rurais <- read_csv(propriedades_rurais_datapath, col_types = cols(id_parlamentar = "c")) %>% 
    select(id_parlamentar, casa, cpf, total_declarado)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, cpf)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()
  
  parlamentares_propriedades_rurais <- parlamentares %>% 
    left_join(propriedades_rurais,
              by = c("cpf", "id" = "id_parlamentar", "casa")) %>% 
    mutate(total_declarado = if_else(is.na(total_declarado), 0, total_declarado))
  
  return(parlamentares_propriedades_rurais)
}

#' @title Recupera informações dos parlamentares que possuem ou não empresas agrícolas
#' @description A partir do dataframe de parlamentares com empresas agrícolas e do
#' dataframe de parlamentares, retorna um dataframe que contém id, cpf e a quatidade de empresas
#' as quais os parlamentares são sócios.
#' @param socios_empresas_rurais_datapath Caminho para o dataframe de parlamentares sócios de
#' empresas rurais
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e a quantidade de empresas.
calcula_score_socios_empresas_rurais <- function(
  socios_empresas_rurais_datapath = here::here("parlametria/raw_data/empresas/socios_empresas_agricolas_todos_parlamentares.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  socios_empresas_rurais <- read_csv(socios_empresas_rurais_datapath, col_types = cols(id_parlamentar = "c")) %>% 
    distinct() %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(numero_empresas_associadas = n_distinct(cnpj)) %>% 
    select(id_parlamentar, casa, numero_empresas_associadas)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, cpf)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()
  
  parlamentares_socios_empresas_rurais <- parlamentares %>% 
    left_join(socios_empresas_rurais,
              by = c("id" = "id_parlamentar", "casa")) %>% 
    mutate(numero_empresas_associadas = if_else(is.na(numero_empresas_associadas), 0, as.numeric(numero_empresas_associadas)))
  
  return(parlamentares_socios_empresas_rurais)
}

#' @title Recupera informações dos parlamentares que receberam doações de empresas agrícolas
#' @description A partir do dataframe de doações de parlamentares que são empresas agrícolas 
#' ou de sócios de empresas agrícolas, e do dataframe de parlamentares, 
#' retorna um dataframe com informações do parlamentar e das doações
#' @param doadores_gerais_2018_datapath Caminho para o dataframe com todos os doadores de campanha para deputados e senadores
#' @param doadores_socios_empresas_rurais_2018_datapath Caminho para o dataframe de doações de campanha  para deputados e senadores
#' de sócios de empresas rurais em 2018
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e proporção de doações de 
#' empresas rurais em relação ao total doado
calcula_score_doacoes_empresas_rurais <- function(
  doadores_gerais_2018_datapath = here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv"),
  doadores_socios_empresas_rurais_2018_datapath = here::here("parlametria/raw_data/empresas/empresas_doadores_agricolas_todos_parlamentares.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  doadores <- read_csv(doadores_gerais_2018_datapath, col_types = cols(id = "c"))
  
  doadores_totais <- doadores %>%
    group_by(id, casa) %>% 
    summarise(total_doacao = sum(valor_receita)) %>% 
    select(id, casa, total_doacao)
  
  doadores_rurais_todos <- read_csv(doadores_socios_empresas_rurais_2018_datapath, col_types = cols(id_parlamentar = "c")) %>% 
    group_by(cpf_cnpj_socio) %>% 
    summarise(n = n())
  
  doadores_rurais <- doadores %>% 
    left_join(doadores_rurais_todos, by = c("cpf_cnpj_doador" = "cpf_cnpj_socio")) %>% 
    filter(!is.na(n)) %>% 
    group_by(id, casa) %>% 
    summarise(total_doacao_agro = sum(valor_receita))
  
  indice_doadores <- doadores_totais %>% 
    inner_join(doadores_rurais, by = c("id", "casa")) %>% 
    mutate(proporcao_doacoes_agro = total_doacao_agro/total_doacao)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, cpf)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()
  
  parlamentares_doacoes <- parlamentares %>% 
    left_join(indice_doadores, by = c("id", "casa"))
  
  return(parlamentares_doacoes)
}

#' @title Recupera informações dos parlamentares que receberam doações de empresas agrícolas exportadoras
#' @description A partir do dataframe de doações a parlamentares durante as eleições de 2018 recupera informações sobre
#' essas doações considerando sócios de empresas agroexportadoras e parlamentares em exercício
#' @param doadores_gerais_2018_datapath Caminho para o dataframe com todos os doadores de campanha
#' @param doadores_socios_empresas_rurais_2018_datapath Caminho para o dataframe de doações de campanha 
#' de sócios de empresas rurais em 2018
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe contendo informações dos parlamentares (cpf e id) e proporção de doações de 
#' empresas agrícolas agroexportadoras em relação ao total doado
calcula_score_doacoes_empresas_agroexportadoras <- function(
  doadores_gerais_2018_datapath = here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv"),
  doadores_socios_empresas_rurais_2018_datapath = here::here("parlametria/raw_data/empresas/empresas_doadores_agricolas_todos_parlamentares.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")
) {
  library(tidyverse)
  library(here)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))

  doadores <- read_csv(doadores_gerais_2018_datapath, col_types = cols(id = "c"))
  
  lista_doado_por_parlamentar <- doadores %>%
    group_by(id, casa) %>% 
    summarise(total_doacao = sum(valor_receita)) %>% 
    select(id, casa, total_doacao)
  
  lista_doadores_agroexportadoras <- read_csv(doadores_socios_empresas_rurais_2018_datapath, col_types = cols(id_parlamentar = "c")) %>% 
    filter(exportadora == "sim") %>% 
    group_by(cpf_cnpj_socio) %>% 
    summarise(n = n())
  
  doadores_agroexportadoras <- doadores %>% 
    left_join(lista_doadores_agroexportadoras, by = c("cpf_cnpj_doador" = "cpf_cnpj_socio")) %>% 
    filter(!is.na(n)) %>% 
    group_by(id, casa) %>% 
    summarise(total_doacao_agro_exportadora = sum(valor_receita))
  
  indice_doadores <- lista_doado_por_parlamentar %>% 
    inner_join(doadores_agroexportadoras, by = c("id", "casa")) %>% 
    mutate(proporcao_doacoes_agroexportadoras = total_doacao_agro_exportadora/total_doacao)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, cpf)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()
  
  parlamentares_doacoes <- parlamentares %>% 
    left_join(indice_doadores, by = c("id", "casa")) %>% 
    mutate(proporcao_doacoes_agroexportadoras = if_else(is.na(proporcao_doacoes_agroexportadoras), 
                                                        0, 
                                                        proporcao_doacoes_agroexportadoras))
  
  return(parlamentares_doacoes)
}

#' @title Recupera lista de empresas agrícolas exportadoras com parlamentares como sócios
#' @description A partir da lista de empresas agrícolas dos parlamentares filtra para obter apenas as empresas exportadoras.
#' Dados de exportação segundo o Ministério da Economia.
#' @param empresas_parlamentares Caminho para o csv com dados de empresas agrícolas com parlamentares como sócios
#' @return Dataframe com empresas agroexportadoras com parlamentares como sócio
#' @example parlamentares_socios_agro_exportadoras <- get_empresas_agroexportadoras_parlamentares()
get_empresas_agroexportadoras_parlamentares <- function(
  empresas_parlamentares = here::here("parlametria/raw_data/empresas/socios_empresas_agricolas_todos_parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("parlametria/crawler/empresas/process_empresas_exportadoras.R"))
  
  dados_empresas_parlamentares <- read_csv(empresas_parlamentares, col_types = cols(id_parlamentar = "c"))
  
  dados_empresas_parlamentares_exportadoras <- dados_empresas_parlamentares %>% 
    classifica_empresas_exportacao()
  
  return(dados_empresas_parlamentares_exportadoras)
}

#' @title Recupera informações dos deputados sócios de empresas agroexportadoras
#' @description Recupera informações dos deputados sócios de empresas agroexportadoras segundo a Receita Federal e o Ministério da Economia
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares
#' @return Dataframe com deputados e coluna que define a participação ou não como sócio de empresas agroexportadoras
#' @example parlamentares_socios_agro_exportadoras <- calcula_sociedade_empresas_agroexportadoras()
calcula_sociedade_empresas_agroexportadoras <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  empresas_socios <- get_empresas_agroexportadoras_parlamentares() %>% 
    select(id = id_parlamentar, exportadora) %>% 
    mutate(exportadora = if_else(exportadora == "sim", 1, 0)) %>% 
    filter(exportadora == 1) %>% 
    distinct(id, .keep_all = TRUE)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, cpf)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()
  
  parlamentares_socios <- parlamentares %>% 
    left_join(empresas_socios, by = c("id", "casa")) %>% 
    mutate(tem_empresa_agroexportadora = if_else(is.na(exportadora), 0, exportadora)) %>% 
    select(id, casa, cpf, tem_empresa_agroexportadora)
  
  return(parlamentares_socios)
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
  tem_empresa_exportadora <- calcula_sociedade_empresas_agroexportadoras()
  doacoes_parlamentares_agroexportadoras <- calcula_score_doacoes_empresas_agroexportadoras()
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, cpf, nome_eleitoral, uf, sg_partido)
  
  indice_vinculo_economico <- parlamentares %>% 
    left_join(propriedades_rurais, by = c("id", "cpf")) %>% 
    left_join(socios, by = c("id", "cpf")) %>% 
    left_join(doacoes, by = c("id", "cpf")) %>% 
    left_join(tem_empresa_exportadora, by = c("id", "cpf")) %>% 
    left_join(doacoes_parlamentares_agroexportadoras, by = c("id", "cpf")) %>% 
    select(id, cpf, nome_eleitoral, uf, sg_partido, total_declarado, numero_empresas_associadas, 
           proporcao_doacoes_agro, tem_empresa_agroexportadora, proporcao_doacoes_agroexportadoras)
  
  return(indice_vinculo_economico)
}

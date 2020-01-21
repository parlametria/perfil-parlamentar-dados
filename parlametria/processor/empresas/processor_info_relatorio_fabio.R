#' @title Processa os dados sobre as atividades econômicas das empresas
#' @description Retorna um dataframe contendo informações sobre as atividades econômicas das empresas no formato do BD.
#' @param parlamentares_datapath Caminho para o dataframe com as informações de parlamentares
#' @return Dataframe com dados processados de atividades econômicas das empresas
#' ARQUIVO 2 - Parlamentares sócios de empresas
processa_atividades_economicas_empresas <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
  info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  source(here("parlametria/processor/empresas/processa_empresas.R"))
  source(here("bd/processor/atividades_economicas/processa_atividades_economicas.R"))
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, nome_eleitoral, sg_partido, uf)
  
  empresas_cnaes <- process_cnaes_empresas(info_empresas_datapath) %>% 
    select(cnpj, cnae_tipo, cnae_codigo, grupo_atividade_economica)
  
  empresas <- process_empresas(info_empresas_datapath) %>% 
    mutate(cnae_codigo = as.character(cnae_codigo)) %>% 
    left_join(empresas_cnaes, by = c("cnpj", "cnae_tipo", "cnae_codigo")) %>% 
    filter(cnae_tipo == "cnae_fiscal") %>% 
    distinct()
  
  empresas_filtered <- empresas %>% 
    inner_join(parlamentares, 
               by = c("id_parlamentar" = "id",
                      "casa"))
  
  empresas_alt <- empresas_filtered %>% 
    select(grupo_atividade_economica,
           id_parlamentar,
           nome_eleitoral,
           sg_partido,
           uf,
           cnpj,
           razao_social,
           data_entrada_sociedade) %>% 
    distinct()
  
  return(empresas_alt)
}

#' @title Processa os dados sobre as atividades econômicas das empresas
#' @description Retorna um dataframe contendo informações sobre as atividades econômicas das empresas no formato do BD.
#' @return Dataframe com dados processados de atividades econômicas das empresas
#' ARQUIVO 3 - Doadores que são sócios de empresas
processa_atividades_economicas_empresas_doadores <- function() {
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  
  parlamentares_doacoes <- read_csv(here("parlametria/raw_data/receitas/parlamentares_doadores.csv"), 
                                    col_types = cols(id = "c")) %>% 
    rename(id_parlamentar = id)
  
  parlamentares_doadores_empresas <- read_csv(here("parlametria/raw_data/empresas/empresas_doadores_todos_parlamentares.csv"),
                                              col_types = cols(id_parlamentar = "c", cnpj_empresa = "c", cpf_cnpj_socio = "c")) %>% 
    mutate(cnpj = stringr::str_pad(cnpj_empresa, 14, pad = "0")) %>% 
    select(id_parlamentar, casa = casa_parlamentar, cnpj, cpf_cnpj_socio) %>% 
    distinct(id_parlamentar, casa, cnpj, cpf_cnpj_socio)
  
  info_empresas <- process_cnaes_empresas(info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_doadores_todos_parlamentares.csv")) %>% 
    distinct(cnpj, razao_social, grupo_atividade_economica)
  
  parlamentares_socios_atividades <- parlamentares_doadores_empresas %>% 
    left_join(info_empresas, by = "cnpj") %>% 
    ## recuperando distintas atividades econômicas por parlamentar e doador (que também é sócio)
    distinct(id_parlamentar, casa, cnpj, razao_social, cpf_cnpj_socio, grupo_atividade_economica)
  
  parlamentares_doacoes_merge <- parlamentares_doacoes %>% 
    select(id_parlamentar, casa, nome_eleitoral, sg_partido, uf, cpf_cnpj_doador, nome_doador, valor_receita) %>% 
    left_join(parlamentares_socios_atividades, by = c("id_parlamentar", "casa", "cpf_cnpj_doador" = "cpf_cnpj_socio"))
  
  parlamentares_doacoes_grouped <- parlamentares_doacoes_merge %>% 
    filter(!is.na(grupo_atividade_economica)) %>% 
    select(-valor_receita) %>% 
    distinct()
  
  return(parlamentares_doacoes_grouped)
}

#' @title Processa índices de ligação com atividades econômicas
#' @description Com base nos dados de parlamentares sócios de empresas e dos sócios de empresas que doaram nas eleições de 2018
#' processa os índices de ligação por atividade econômica dos parlamentares
#' @return Dataframe contendo informações dos índices dos parlamentares por atividade econômica
#' @examples
#' indices_atividades_economicas <- processa_indice_geral_ligacao_economica()
#' ARQUIVO 1 - Índice Geral de Ligação Econômica
processa_indice_geral_ligacao_economica <- function() {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  source(here("parlametria/processor/empresas/processor_indice_atividades_economicas.R"))
  
  ## Considera parlamentares em exercício ou não
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id_parlamentar = id, casa, nome_eleitoral, sg_partido, uf)
  
  parlamentares_socios_atividades_economicas <- processa_parlamentares_socios_atividades_economicas()
  
  parlamentares_proporcao_doadores_atividades_economicas <- processa_proporcao_doadores_atividades_economicas()
  
  parlamentares_alt <- parlamentares_socios_atividades_economicas %>% 
    full_join(parlamentares_proporcao_doadores_atividades_economicas, 
              by = c("id_parlamentar", "casa", "grupo_atividade_economica")) %>% 
    inner_join(parlamentares_id, by = c("id_parlamentar", "casa")) %>% 
    
    mutate_at(
      .funs = list( ~ replace_na(., 0)),
      .vars = vars(
        n_empresas,
        tem_empresa,
        total_por_atividade,
        total_recebido_geral,
        proporcao_doacao
      )
    ) %>% 
    
    mutate(indice_ligacao_atividade_economica =
             (2 * tem_empresa + 1.5 * proporcao_doacao) / 3.5) %>% 
    select(id_parlamentar, casa, nome_eleitoral, sg_partido, uf, grupo_atividade_economica, 
           n_empresas, total_por_atividade, total_recebido_geral, proporcao_doacao, 
           indice_ligacao_atividade_economica)
  
  return(parlamentares_alt)
}

#' @title Realiza merge entre a sugestão de novos nomes para os grupos econômicos e os códigos da coluna de
#' divisão no CNAE - IBGE
#' @description Realiza merge entre a sugestão de novos nomes para os grupos econômicos e os códigos da coluna de
#' divisão no CNAE - IBGE
#' @return Dataframe contendo informações dos nome sugeridos para os grupos econômicos e seus códigos de divisão no CNAE
#' @examples
#' merge_nomes_cnae <- merge_divisao_cnaes()
merge_divisao_cnaes <- function() {
  library(tidyverse)
  
  ## Link para planilha: https://docs.google.com/spreadsheets/d/1BcuFkAs1VxjwDmc26TRjKfT1dE71oy8cm2Oz0RjLEKE/edit#gid=188864972
  .URL_SUGESTAO_GRUPOS_BRUNO = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRQyWsXgv-OSdX79ykHLF8zvpviso2mh-yuxEQMUqjZXN3BRFTyDN_gCuec0mlKsB-vTKGyq6jWQs1Z/pub?gid=188864972&single=true&output=csv"
  sugestao <- read_csv(.URL_SUGESTAO_GRUPOS_BRUNO)
  
  ## Link para planilha: https://docs.google.com/spreadsheets/d/1Sy-atPZd4VcIRWKFklo24TLg-PQ93YPosfi8Aj9Jwi8/edit#gid=319930246
  .URL_CNAE_IBGE = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQnCe3_z0B3OYzBWe-1Q-a7FugenhsARmxcbKBn6vGSkRkAbp4EzQSQWTSvWRpQRgEkdNxAZYY2wzPz/pub?gid=319930246&single=true&output=csv"
  
  cnaes <- read_csv(.URL_CNAE_IBGE) %>% 
    select(codigo = `Divisão`, nome = X6) %>% 
    filter(!is.na(codigo))
  
  cnaes_merge <- sugestao %>% 
    left_join(cnaes, by = c("Divisão CNAE" = "nome")) %>% 
    mutate(`Proposta de Agregação` = toupper(`Proposta de Agregação`))
  
  return(cnaes_merge)
}
#' @title Processa os dados sobre as atividades econômicas das empresas
#' @description Retorna um dataframe contendo informações sobre as atividades econômicas das empresas no formato do BD.
#' @param parlamentares_datapath Caminho para o dataframe com as informações de parlamentares
#' @return Dataframe com dados processados de atividades econômicas das empresas
processa_atividades_economicas_empresas <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  source(here("parlametria/processor/empresas/processa_empresas.R"))
  source(here("bd/processor/atividades_economicas/processa_atividades_economicas.R"))
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, nome_eleitoral, sg_partido, uf)
  
  cnaes_enum <- processa_atividade_economica()
  
  empresas_cnaes <- process_cnaes_empresas() %>% 
    select(cnpj, cnae_tipo, cnae_codigo, grupo_atividade_economica)
  
  empresas <- process_empresas() %>% 
    mutate(cnae_codigo = as.character(cnae_codigo)) %>% 
    left_join(empresas_cnaes, by = c("cnpj", "cnae_tipo", "cnae_codigo"))
  
  empresas_filtered <- empresas %>% 
    inner_join(parlamentares, 
               by = c("id_parlamentar" = "id",
                      "casa"))
  
  empresas_alt <- empresas_filtered %>% 
    left_join(cnaes_enum, by = c("grupo_atividade_economica" = "nome")) %>% 
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

#' @title Processa índices de ligação com atividades econômicas
#' @description Com base nos dados de parlamentares sócios de empresas e dos sócios de empresas que doaram nas eleições de 2018
#' processa os índices de ligação por atividade econômica dos parlamentares
#' @return Dataframe contendo informações dos índices dos parlamentares por atividade econômica
#' @examples
#' indices_atividades_economicas <- processa_indices_ligacao_atividade_economica()
#' ARQUIVO 1 - Índice Geral de Ligação Econômica
processa_indice_geral_ligacao_economica <- function() {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  ## Considera parlamentares em exercício ou não
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id_parlamentar = id, casa, nome_eleitoral, sg_partido, uf)
  
  parlamentares_socios_atividades_economicas <- processa_parlamentares_socios_atividades_economicas()
  
  parlamentares_prorporcao_doadores_atividades_economicas <- processa_proporcao_doadores_atividades_economicas()
  
  parlamentares_alt <- parlamentares_socios_atividades_economicas %>% 
    full_join(parlamentares_prorporcao_doadores_atividades_economicas, 
              by = c("id_parlamentar", "casa", "grupo_atividade_economica")) %>% 
    inner_join(parlamentares_id, by = c("id_parlamentar", "casa")) %>% 
    
    mutate_at(
      .funs = list( ~ replace_na(., 0)),
      .vars = vars(
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

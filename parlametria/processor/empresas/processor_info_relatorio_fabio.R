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

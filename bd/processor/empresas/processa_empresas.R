processa_atividade_economica <- function() {
  library(here)
  library(tidyverse)
  
  grupos_atividade_economica <- 
    jsonlite::fromJSON(here("parlametria/processor/empresas/constants.json"))$grupos_cnae$nome %>% 
    as_data_frame() %>% 
    rename(grupo_atividade_economica = value) %>% 
    arrange(grupo_atividade_economica) %>% 
    rowid_to_column("id")
  
  return(grupos_atividade_economica)
}

processa_empresas <- function(
  info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv"),
  parlamentares_socios_datapath = here::here("parlametria/raw_data/empresas/socios_empresas_todos_parlamentares.csv")) {
  library(here)
  library(tidyverse)
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  
  empresas <- process_cnaes_empresas(info_empresas_datapath)
  parlamentares_socios <- read_csv(parlamentares_socios_datapath, col_types = cols(.default = "c")) %>% 
    mutate(casa = if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa, id_parlamentar)) %>% 
    select(id_parlamentar_voz, cnpj)
  
  empresas <- empresas %>% 
    filter(cnae_tipo == 'cnae_fiscal') %>% 
    select(cnpj, razao_social, grupo_atividade_economica) %>% 
    distinct()
  
  atividade_economica <- processa_atividade_economica()
  
  empresas_alt <- empresas %>% 
    left_join(atividade_economica,
              by = "grupo_atividade_economica") %>% 
    select(-grupo_atividade_economica) %>% 
    left_join(parlamentares_socios,
              by = "cnpj") %>% 
    rename(id_grupo_atividade_economica = id) 
  
  return(empresas_alt)

}
#' @title Processa parlamentares que possuem pelo menos uma empresa por atividade econômica
#' @description Processa empresas que possuem parlamentares como sócios e retorna atividades econômicas dessas empresas
#' @return Dataframe com atividades econômicas ligadas a parlamentares que possuem pelo menos uma empresa com CNAE registrado
#' nessa atividade econômica
#' @examples
#' parlamentares_socios_atividades_economicas <- processa_parlamentares_socios_atividades_economicas()
processa_parlamentares_socios_atividades_economicas <- function() {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  
  parlamentares_empresas <- read_csv(here("parlametria/raw_data/empresas/socios_empresas_todos_parlamentares.csv"),
                                     col_types = cols(id_parlamentar = "c")) %>% 
    distinct(id_parlamentar, casa, cnpj)
  
  info_empresas <- process_cnaes_empresas(
    info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv"),
    apenas_cnae_fiscal = TRUE) %>% 
    distinct(cnpj, grupo_atividade_economica)
  
  parlamentares_empresas_cnaes <- parlamentares_empresas %>% 
    left_join(info_empresas, by = "cnpj") %>% 
    group_by(id_parlamentar, casa, grupo_atividade_economica) %>% 
    summarise(n_empresas = n_distinct(cnpj)) %>% 
    ungroup() %>% 
    mutate(tem_empresa = if_else(n_empresas >= 1, 1, 0)) %>% 
    select(id_parlamentar, casa, grupo_atividade_economica, tem_empresa, n_empresas)
  
  return(parlamentares_empresas_cnaes)
}

#' @title Processa proporção de doações para os parlamentares para cada atividade econômica
#' @description A partir dos dados de doadores para parlamentares em 2018, recupera a proporção de doações por atividade 
#' econômica para cada parlamentar
#' @return Dataframe com proporção da doação de sócios por atividade ecomômica para os parlamentares
#' @examples
#' proporcao_doadores_atividades_economicas <- processa_proporcao_doadores_atividades_economicas()
processa_proporcao_doadores_atividades_economicas <- function() {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  source(here("parlametria/processor/empresas/processor_cnaes_empresas.R"))
  
  parlamentares_doacoes <- read_csv(here("parlametria/raw_data/receitas/parlamentares_doadores.csv"), 
                                    col_types = cols(id = "c")) %>% 
    rename(id_parlamentar = id)
 
  parlamentares_doadores_empresas <- read_csv(here("parlametria/raw_data/empresas/empresas_doadores_todos_parlamentares.csv"),
                                     col_types = cols(id_parlamentar = "c", cnpj_empresa = "c", cpf_cnpj_socio = "c")) %>% 
    mutate(cnpj = stringr::str_pad(cnpj_empresa, 14, pad = "0")) %>% 
    select(id_parlamentar, casa = casa_parlamentar, cnpj, cpf_cnpj_socio) %>% 
    distinct(id_parlamentar, casa, cnpj, cpf_cnpj_socio) 
  
  info_empresas <- process_cnaes_empresas(
    info_empresas_datapath = here::here("parlametria/raw_data/empresas/info_empresas_doadores_todos_parlamentares.csv"),
    apenas_cnae_fiscal = TRUE) %>% 
    distinct(cnpj, grupo_atividade_economica)
  
  parlamentares_socios_atividades <- parlamentares_doadores_empresas %>% 
    left_join(info_empresas, by = "cnpj") %>% 
    ## recuperando distintas atividades econômicas por parlamentar e doador (que também é sócio)
    distinct(id_parlamentar, casa, cpf_cnpj_socio, grupo_atividade_economica) %>% 
    group_by(id_parlamentar, casa, cpf_cnpj_socio) %>% 
    mutate(n_grupos_atividades_economicas = n_distinct(grupo_atividade_economica)) %>% 
    ungroup()
  
  parlamentares_doacoes_merge <- parlamentares_doacoes %>% 
    select(id_parlamentar, casa, nome_eleitoral, cpf_cnpj_doador, nome_doador, valor_receita) %>% 
    left_join(parlamentares_socios_atividades, by = c("id_parlamentar", "casa", "cpf_cnpj_doador" = "cpf_cnpj_socio")) %>% 
    filter(!is.na(grupo_atividade_economica)) %>%
    mutate(valor_receita_por_atividade = valor_receita / n_grupos_atividades_economicas)
  
  parlamentares_doacoes_grouped <- parlamentares_doacoes_merge %>% 
    group_by(id_parlamentar, casa, grupo_atividade_economica) %>% 
    summarise(total_por_atividade = sum(valor_receita_por_atividade)) %>% 
    ungroup()
  
  parlamentares_doacoes_geral <- parlamentares_doacoes %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(total_recebido_geral = sum(valor_receita)) %>% 
    ungroup()
  
  parlamentares_doacoes_alt <- parlamentares_doacoes_grouped %>% 
    left_join(parlamentares_doacoes_geral, by = c("id_parlamentar", "casa")) %>% 
    mutate(proporcao_doacao = total_por_atividade / total_recebido_geral)
  
  return(parlamentares_doacoes_alt)
}

#' @title Processa índices de ligação com atividades econômicas
#' @description Com base nos dados de parlamentares sócios de empresas e dos sócios de empresas que doaram nas eleições de 2018
#' processa os índices de ligação por atividade econômica dos parlamentares
#' @return Dataframe contendo informações dos índices dos parlamentares por atividade econômica
#' @examples
#' indices_atividades_economicas <- processa_indices_ligacao_atividade_economica()
processa_indices_ligacao_atividade_economica <- function() {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  ## Considera parlamentares em exercício ou não
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c"))
  # filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id_parlamentar = id, casa)
  
  parlamentares_socios_atividades_economicas <- processa_parlamentares_socios_atividades_economicas() %>% 
    select(-n_empresas)
  
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
             (2 * tem_empresa + 1.5 * proporcao_doacao) / 3.5)
  
  return(parlamentares_alt)
}

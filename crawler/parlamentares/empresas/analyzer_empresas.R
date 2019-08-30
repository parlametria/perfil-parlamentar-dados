#' @title Adiciona dados sobre os deputados, valor doado e se a empresa é exportadora
#' @description A partir de um dataframe de empresas com socios doadores de campanha, adiciona
#' novas informações.
#' @param empresas_agricolas_doadores_datapath Caminho para o dataframe de empresas agricolas cujos
#' socios doaram em campanhas
#' @return Dataframe com mais dados sobre os deputados, valor doado e se a empresa é exportadora
#' @example process_empresas_doadores()
process_empresas_doadores <- function(
  empresas_agricolas_doadores_datapath = here::here("crawler/raw_data/empresas_doadores_agricolas_raw.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))
  source(here("crawler/parlamentares/empresas/fetch_empresas.R"))
  
  parlamentares_doacoes <- processa_doacoes_deputados_tse() %>% 
    filter(casa == "camara") %>% 
    select(id, 
           nome_deputado = nome_eleitoral, 
           partido_deputado = sg_partido, 
           uf_deputado = uf, 
           valor_doado = valor_receita,
           cpf_cnpj_doador,
           nome_doador) %>% 
    mutate(id = as.character(id),
           cpf_cnpj_doador = as.character(cpf_cnpj_doador))
  
  empresas_doadores <- read_csv(empresas_agricolas_doadores_datapath,
                                col_types = cols(.default = "c"))
  
  empresas_doadores_com_nome_deputado <- empresas_doadores %>% 
    left_join(parlamentares_doacoes, by = c("id_deputado" = "id", "nome_socio" = "nome_doador")) %>% 
    rename(cpf_cnpj_socio = cnpj_cpf_do_socio) %>% 
    mutate(cpf_cnpj_socio = cpf_cnpj_doador) %>% 
    select(-cpf_cnpj_doador)
  
 res <- classifica_empresas_exportacao(empresas_doadores_com_nome_deputado)
 
 res <- res %>% 
   select(cnpj_empresa = cnpj,
          exportadora,
          cpf_cnpj_socio,
          nome_socio,
          data_entrada_sociedade, 
          id_deputado,
          nome_deputado,
          partido_deputado,
          uf_deputado,
          valor_doado)
  
  return(res)
  
}

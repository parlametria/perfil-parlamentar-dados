#' @title Constrói indíce de vínculo com agro a partir de vários datasets
#' @description Junta várias bases de dados para construir índice de vínculo com o Agronegócio para parlamentares em exercício
#' @return Dataframe contendo colunas que compõem o índice de vínculo com o Agronegócio
#' @examples
#' vinculo <- process_indice_vinculo_agro()
process_indice_vinculo_agro <- function() {
  library(tidyverse)
  library(here)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id)
  
  propriedades_rurais <- read_csv(here("parlametria/raw_data/patrimonio/propriedades_rurais.csv"),
                                  col_types = cols(id_parlamentar = "c")) %>% 
    mutate(tem_propriedade_rural = if_else(n_propriedades >= 1, 1, 0)) %>% 
    select(id_parlamentar, casa, tem_propriedade_rural)
  
  empresas_rurais <- read_csv(here("parlametria/raw_data/empresas/socios_empresas_agricolas_todos_parlamentares.csv"),
                              col_type = cols(id_parlamentar = "c")) %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(n_empresas_agricolas = n_distinct(cnpj)) %>% 
    mutate(tem_empresa_agricola = if_else(n_empresas_agricolas >= 1, 1, 0)) %>% 
    select(id_parlamentar, casa, tem_empresa_agricola)
  
  doacoes_agro <- read_csv(here("parlametria/raw_data/score_ruralistas/indice_vinculo_economico_agro.csv"),
                           col_types = cols(id = "c")) %>% 
    select(id, proporcao_doacoes_agro, tem_empresa_agroexportadora, proporcao_doacoes_agroexportadoras)
  
  deputados_processed <- deputados_id %>% 
    
    left_join(propriedades_rurais, by = c("id" = "id_parlamentar", "casa")) %>%
    left_join(empresas_rurais, by = c("id" = "id_parlamentar", "casa")) %>% 
    
    left_join(doacoes_agro, by = "id") %>% 
    select(id, tem_propriedade_rural, total_declarado_propriedade_rural, tem_empresa_agricola, proporcao_doacoes_agro,
           tem_empresa_agroexportadora, proporcao_doacoes_agroexportadoras) %>%
    
    ## Substituindo NA por 0
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(tem_propriedade_rural,
                                                           total_declarado_propriedade_rural,
                                                           tem_empresa_agricola,
                                                           proporcao_doacoes_agro
                                                           )
              ) %>% 
    
    ## Cálculo do vínculo econômico com o Agro
    mutate(indice_vinculo_economico_agro = 
             (tem_empresa_agricola*2 + proporcao_doacoes_agro*1.5 + tem_propriedade_rural) / 4.5)
  
  return(deputados_processed)
}

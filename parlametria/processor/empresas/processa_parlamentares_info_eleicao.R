#' @title Processa informações dos parlamentares na eleição como total recebido_geral, pelos partidos e por sócios de empresas
#' @description A partir dos dados de doadores para parlamentares em 2018, recupera informações sobre os parlamentares e a origem 
#' do dinheiro recebido através de doações.
#' @return Dataframe com informações das doações para parlamentares em 2018
#' @examples
#' parlamentares_info_eleicao <- processa_parlamentares_info_eleicao()
processa_parlamentares_info_eleicao <- function() {
  library(tidyverse)
  library(here)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id_parlamentar = id, casa, nome_eleitoral, sg_partido, uf)
  
  parlamentares_doacoes <- read_csv(here("parlametria/raw_data/receitas/parlamentares_doadores.csv"), col_types = cols(id = "c")) %>% 
    rename(id_parlamentar = id)
  
  doacoes_sumario <- read_csv(here("parlametria/raw_data/empresas/parlamentares_ligacao_atividade_economica.csv"),
                              col_types = cols(id_parlamentar = "c"))
  
  doacoes_sumario_soma <- doacoes_sumario %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(total_receita_doadores_empresas = sum(total_por_atividade))
  
  parlamentares_doacoes_geral <- parlamentares_doacoes %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(total_recebido_geral = sum(valor_receita)) %>% 
    ungroup()
  
  parlamentares_doacoes_origem <- parlamentares_doacoes %>% 
    mutate(origem = case_when(
      origem_receita == "Recursos de partido político" ~ "origem_partido",
      origem_receita == "Recursos de outros candidatos" ~ "outros_candidatos",
      TRUE ~ "pessoa_fisica",
    )) %>% 
    group_by(id_parlamentar, casa, origem) %>% 
    summarise(total_por_origem = sum(valor_receita)) %>% 
    ungroup() %>% 
    spread(key = "origem", value = "total_por_origem")
    
  parlamentares_info_eleicao <- parlamentares %>% 
    left_join(parlamentares_doacoes_origem, by = c("id_parlamentar", "casa")) %>% 
    left_join(parlamentares_doacoes_geral, by = c("id_parlamentar", "casa")) %>% 
    left_join(doacoes_sumario_soma, by = c("id_parlamentar", "casa")) %>% 
    mutate_at(
      .funs = list( ~ replace_na(., 0)),
      .vars = vars(
        origem_partido,
        outros_candidatos,
        pessoa_fisica,
        total_receita_doadores_empresas,
        total_recebido_geral
      )
    ) %>% 
    select(id_parlamentar, casa, nome_eleitoral, sg_partido, uf, origem_partido, outros_candidatos, pessoa_fisica, 
           total_receita_doadores_empresas, total_recebido_geral)
    
  
  return(parlamentares_info_eleicao)
}
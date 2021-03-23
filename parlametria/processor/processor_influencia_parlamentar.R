library(tidyverse)
library(here)
source(here::here("parlametria/processor/peso_politico/process_movimentos_renovacao.R"))
source(here::here("parlametria/processor/peso_politico/process_investimento_partidario.R"))
source(here::here("parlametria/processor/peso_politico/process_cargos_politicos.R"))
source(here::here("parlametria/processor/peso_politico/process_cargos_comissoes.R"))
source(here::here("parlametria/processor/peso_politico/process_cargos_liderancas.R"))
source(here::here("parlametria/processor/peso_politico/process_cargos_mesa.R"))

#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
process_indice_influencia_parlamentar <- function() {
  options(scipen=999)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id, casa)
  
  movimentos_renovacao <- process_movimentos_renovacao()
  
  investimento_partidario <- process_investimento_partidario()
  
  mandatos_cargos <- process_cargos_politicos()
  
  n_max_comissoes <- process_max_comissoes()
    
  indice_comissoes_cargos <- process_cargos_comissoes(n_max_comissoes)
    
  lideranca_partido <- process_cargos_liderancas()
  
  cargos_mesa <- process_cargos_mesa()
  
  parlamentares_processed <- parlamentares_id %>% 
    left_join(movimentos_renovacao, by = c("id", "casa")) %>% 
    left_join(investimento_partidario, by = c("id", "casa")) %>% 
    left_join(mandatos_cargos, by = c("id" = "id_parlamentar", "casa" = "casa")) %>% 
    left_join(indice_comissoes_cargos, by = c("id", "casa")) %>% 
    left_join(lideranca_partido, by = c("id", "casa")) %>% 
    left_join(cargos_mesa, by = c("id", "casa")) %>% 
    ## Substituindo NA por 0
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(participou_movimento_renovacao,
                                                            investimento_partidario,
                                                            indice_comissoes,
                                                            indice_liderancas,
                                                            indice_cargo_mesa)
              ) %>% 
    ## Substituindo NA no número de mandatos por 1 (parlamentar está em exercício apesar da suplência)
    mutate(numero_de_mandatos = ifelse(is.na(numero_de_mandatos), 1, numero_de_mandatos)) %>% 
    mutate(
      indice_influencia_parlamentar =
        (
          investimento_partidario * 2 + indice_liderancas * 4 + indice_comissoes *
            2 + indice_cargo_mesa * 6 + numero_de_mandatos * 1
        ) / 15
    ) %>%   ## 15 é a soma dos pesos (2+4+2+6+1)
    mutate(indice_influencia_parlamentar = indice_influencia_parlamentar / max(indice_influencia_parlamentar))

  return(parlamentares_processed)
}

#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
processor_influencia_parlamentar <- function() {
  library(tidyverse)
  library(here)
  options(scipen=999)
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  deputados_id <- deputados %>% 
    select(id)
  
  movimentos_renovacao <- read_csv(here("parlametria/crawler/movimentos_renovacao/movimentos_renovacao.csv"),
                                   col_types = cols(id = "c")) %>% 
    select(id, grupos) %>% 
    mutate(participou_movimento_renovacao = if_else(is.na(grupos), 0, 1)) %>% 
    select(-grupos)
  
  investimento_partidario <- read_csv(here("parlametria/raw_data/resumo/parlamentares_investimento.csv"),
                                      col_types = cols(id = "c")) %>% 
    select(id, investimento_partidario = proporcao_campanhas_medias_receita)
  
  mandatos_cargos <- read_csv(here("parlametria/raw_data/cargos_politicos/historico_parlamentares_cargos_politicos.csv"),
                              col_types = cols(id_parlamentar = "c")) %>% 
    group_by(id_parlamentar) %>% 
    summarise(numero_de_mandatos = n_distinct(ano_eleicao))
  
  lideranca_partido <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                     col_types = cols(id = "c")) %>% 
    select(id, Líder) %>% 
    mutate(lideranca_partido = if_else(is.na(Líder), 0, 1)) %>% 
    select(-Líder)
  
  titularidade_comissoes <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                     col_types = cols(id = "c")) %>% 
    select(id, Titular) %>% 
    separate_rows(Titular, sep = ";") %>% 
    group_by(id) %>% 
    summarise(n_comissoes = n_distinct(Titular))
    
  ## TODO: porcentagem dos votos recebidos em 2018 com relação a UF e ao partido
  
  deputados_processed <- deputados_id %>% 
    left_join(movimentos_renovacao, by = "id") %>% 
    left_join(investimento_partidario, by = "id") %>% 
    left_join(mandatos_cargos, by = c("id" = "id_parlamentar")) %>% 
    left_join(lideranca_partido, by = "id") %>% 
    left_join(titularidade_comissoes, by = "id") %>% 
    ## Substituindo NA por 0
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(participou_movimento_renovacao,
                                                           investimento_partidario)
              ) %>% 
    
    mutate(indice_influencia_parlamentar = 
             (lideranca_partido + n_comissoes + (numero_de_mandatos / 6)) / 3)

  return(deputados_processed)
}
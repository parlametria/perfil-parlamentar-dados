#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
process_indice_influencia_parlamentar <- function() {
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
  
  n_max_comissoes <-  read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                               col_types = cols(id = "c")) %>% 
    select(id, Titular) %>% 
    separate_rows(Titular, sep = ";") %>% 
    filter(!is.na(Titular)) %>% 
    count(id) %>% 
    pull(n) %>% 
    max()
    
  indice_comissoes_cargos <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                     col_types = cols(id = "c")) %>% 
    select(id, 
           Presidente, 
           `Primeiro Vice-presidente`,
           `Segundo Vice-presidente`, 
           `Terceiro Vice-presidente`,
           Titular) %>% 
    gather(key = "cargo", value = "comissao", Presidente:Titular) %>% 
    filter(!is.na(comissao)) %>% 
    separate_rows(comissao, sep = ";") %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Presidente") ~ 4,
      str_detect(cargo, "Primeiro Vice-presidente") ~ 3,
      str_detect(cargo, "Segundo Vice-presidente") ~ 2,
      str_detect(cargo, "Terceiro Vice-presidente") ~ 1,
      str_detect(cargo, "Titular") ~ 1 / n_max_comissoes,
    )) %>% 
    group_by(id) %>% 
    summarise(score_comissoes = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_comissoes = score_comissoes / 11 ) %>%  ## 11 é a soma dos pesos 4 + 3 + 2 + 1 + 1 (peso máximo para comissões)
    select(id, indice_comissoes)
    
  lideranca_partido <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                     col_types = cols(id = "c")) %>% 
    select(id, Líder, `Vice-líder`, `Representante`) %>%
    gather(key = "cargo", value = "partido", Líder:Representante) %>% 
    filter(!is.na(partido)) %>% 
    separate_rows(partido, sep = ";") %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Líder") ~ 3,
      str_detect(cargo, "Vice-líder") ~ 2,
      str_detect(cargo, "Representante") ~ 3
    )) %>% 
    group_by(id) %>% 
    summarise(score_liderancas = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_liderancas = score_liderancas / 8) %>%  ## 8 é a soma dos pesos 3 + 2 + 3
    select(id, indice_liderancas)
  
  ## TODO: porcentagem dos votos recebidos em 2018 com relação a UF e ao partido
  
  deputados_processed <- deputados_id %>% 
    left_join(movimentos_renovacao, by = "id") %>% 
    left_join(investimento_partidario, by = "id") %>% 
    left_join(mandatos_cargos, by = c("id" = "id_parlamentar")) %>% 
    left_join(indice_comissoes_cargos, by = "id") %>% 
    left_join(lideranca_partido, by = "id") %>% 
    ## Substituindo NA por 0
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(participou_movimento_renovacao,
                                                           investimento_partidario,
                                                           indice_comissoes,
                                                           indice_liderancas)
              ) %>% 
    
    mutate(indice_influencia_parlamentar = 
             (indice_liderancas + indice_comissoes + (numero_de_mandatos / 6)) / 3)

  return(deputados_processed)
}
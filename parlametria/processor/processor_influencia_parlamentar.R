#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
process_indice_influencia_parlamentar <- function() {
  library(tidyverse)
  library(here)
  options(scipen=999)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id, casa)
  
  movimentos_renovacao <- read_csv(here("parlametria/crawler/movimentos_renovacao/movimentos_renovacao.csv"),
                                   col_types = cols(id = "c")) %>% 
    mutate(casa = case_when(
      str_detect(cargo, "Deputad") ~ "camara",
      str_detect(cargo, "Senad") ~ "senado",
      TRUE ~ NA_character_
    )) %>% 
    select(id, casa, grupos) %>% 
    mutate(participou_movimento_renovacao = if_else(is.na(grupos), 0, 1)) %>% 
    select(-grupos)
  
  investimento_partidario <- read_csv(here("parlametria/raw_data/resumo/parlamentares_investimento.csv"),
                                      col_types = cols(id = "c")) %>% 
    filter(sg_partido == partido_eleicao,
           em_exercicio == 1) %>% 
    select(id, casa, investimento_partidario = proporcao_campanhas_medias_receita) %>% 
    distinct()
  
  mandatos_cargos <- read_csv(here("parlametria/raw_data/cargos_politicos/historico_parlamentares_cargos_politicos.csv"),
                              col_types = cols(id_parlamentar = "c")) %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(numero_de_mandatos = n_distinct(ano_eleicao))
  
  n_max_comissoes <-  read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                               col_types = cols(id = "c")) %>% 
    select(id, casa, Titular) %>% 
    separate_rows(Titular, sep = ";") %>% 
    filter(!is.na(Titular)) %>% 
    count(id, casa) %>% 
    group_by(casa) %>% 
    summarise(max = max(n)) %>% 
    rename(casa_parlamentar = casa)
    
  indice_comissoes_cargos <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                     col_types = cols(id = "c")) %>% 
    select(id,
           casa,
           Presidente, 
           `Primeiro Vice-presidente`,
           `Segundo Vice-presidente`, 
           `Terceiro Vice-presidente`,
           Titular) %>% 
    gather(key = "cargo", value = "comissao", Presidente:Titular) %>% 
    filter(!is.na(comissao)) %>% 
    separate_rows(comissao, sep = ";") %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Presidente") ~ 4,
      str_detect(cargo, "Primeiro Vice-presidente") ~ 3,
      str_detect(cargo, "Segundo Vice-presidente") ~ 2,
      str_detect(cargo, "Terceiro Vice-presidente") ~ 1,
      str_detect(cargo, "Titular") ~ 1 / (n_max_comissoes %>% filter(casa_parlamentar == casa) %>% pull(max))
    )) %>% 
    ungroup() %>% 
    group_by(id, casa) %>% 
    summarise(score_comissoes = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_comissoes = score_comissoes / 11 ) %>%  ## 11 é a soma dos pesos 4 + 3 + 2 + 1 + 1 (peso máximo para comissões)
    select(id, casa, indice_comissoes)
    
  lideranca_partido <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                     col_types = cols(id = "c")) %>% 
    select(id, casa, Líder, `Vice-líder`, `Representante`) %>%
    gather(key = "cargo", value = "partido", Líder:Representante) %>% 
    filter(!is.na(partido)) %>% 
    separate_rows(partido, sep = ";") %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Líder") ~ 3,
      str_detect(cargo, "Vice-líder") ~ 2,
      str_detect(cargo, "Representante") ~ 3
    )) %>% 
    group_by(id, casa) %>% 
    summarise(score_liderancas = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_liderancas = score_liderancas / 8) %>%  ## 8 é a soma dos pesos 3 + 2 + 3
    select(id, casa, indice_liderancas)
  
  cargos_mesa <- read_csv(here("crawler/raw_data/cargos_mesa.csv")) %>% 
    mutate(id = as.character(id_parlamentar)) %>% 
    mutate(indice_cargo_mesa = case_when(
      str_detect(cargo, "Suplente de Secretário|Suplente") ~ 0.2,
      str_detect(cargo, "Secretário") ~ 0.6,
      str_detect(cargo, "Vice-Presidente") ~ 0.8,
      str_detect(cargo, "Presidente") ~ 1,
      TRUE ~ 0)) %>% 
    select(id, casa, indice_cargo_mesa)
  
  ## TODO: porcentagem dos votos recebidos em 2018 com relação a UF e ao partido
  
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
    
    mutate(indice_influencia_parlamentar = 
             (investimento_partidario + indice_liderancas + indice_comissoes + indice_cargo_mesa + (numero_de_mandatos / 6)) / 5)

  return(parlamentares_processed)
}
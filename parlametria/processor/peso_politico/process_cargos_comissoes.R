library(tidyverse)
library(here)

#' @title Processa Número máximo de comissões ocupadas por um parlamentar por casa
#' @description Cria dataframe com o número máximo de comissões ocupadas por um parlamentar por casa
#' @return Dataframe contendo número máximo de comissões ocupadas
process_max_comissoes <- function() {
  n_max_comissoes <-  read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                 col_types = cols(id = "c")) %>% 
      select(id, casa, Titular) %>% 
      separate_rows(Titular, sep = ";") %>% 
      filter(!is.na(Titular)) %>% 
      count(id, casa) %>% 
      group_by(casa) %>% 
      summarise(max = max(n)) %>% 
      rename(casa_parlamentar = casa)
  
  return(n_max_comissoes)
}

#' @title Processa Cargos em Comissões
#' @description Recupera parlamentares e o índice de cargos ocupados em comissões
#' @param n_max_comissoes Dataframe com número máximo de comissões ocupadas por um parlamentar por casa
#' @return Dataframe contendo lista de parlamentares e o índice/peso de cargos ocupados em comissões
process_cargos_comissoes <- function(n_max_comissoes) {
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
      str_detect(cargo, "Presidente") ~ 1,
      str_detect(cargo, "Primeiro Vice-presidente") ~ 0.3,
      str_detect(cargo, "Segundo Vice-presidente") ~ 0.1,
      str_detect(cargo, "Terceiro Vice-presidente") ~ 0.05,
      str_detect(cargo, "Titular") ~ 0 / (n_max_comissoes %>% filter(casa_parlamentar == casa) %>% pull(max))
    )) %>% 
    ungroup() %>% 
    group_by(id, casa) %>% 
    summarise(score_comissoes = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_comissoes = score_comissoes / max(score_comissoes)) %>% 
    select(id, casa, indice_comissoes)
  
  return(indice_comissoes_cargos)
}

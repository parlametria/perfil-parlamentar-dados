library(tidyverse)
library(here)

#' @title Processa Cargos em Lideranças
#' @description Recupera parlamentares e o índice de cargos ocupados em lideranças
#' @return Dataframe contendo lista de parlamentares e o índice/peso de cargos ocupados em lideranças
process_cargos_liderancas <- function() {
  lideranca_partido <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                col_types = cols(id = "c")) %>% 
    select(id, casa, Líder, `Vice-líder`, `Representante`) %>%
    gather(key = "cargo", value = "partido", Líder:Representante) %>% 
    filter(!is.na(partido)) %>% 
    separate_rows(partido, sep = ";") %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Líder") ~ 3,
      str_detect(cargo, "Vice-líder") ~ 0,
      str_detect(cargo, "Representante") ~ 3
    )) %>% 
    group_by(id, casa) %>% 
    summarise(score_liderancas = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_liderancas = score_liderancas / max(score_liderancas)) %>% 
    select(id, casa, indice_liderancas)
  
  return(lideranca_partido)
}
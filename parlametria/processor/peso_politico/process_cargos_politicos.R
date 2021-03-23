library(tidyverse)
library(here)

#' @title Processa Cargos Políticos
#' @description Recupera lista de parlamentares e o número de mandatos em cargos políticos já ocupados
#' @return Dataframe contendo lista de parlamentares e o número de mandatos em cargos políticos já ocupados
process_cargos_politicos <- function() {
  mandatos_cargos <- read_csv(here("parlametria/raw_data/cargos_politicos/historico_parlamentares_cargos_politicos.csv"),
                              col_types = cols(id_parlamentar = "c")) %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(numero_de_mandatos = n_distinct(ano_eleicao)) %>% 
    ungroup() %>% 
    mutate(numero_de_mandatos = (numero_de_mandatos - 1) / (max(numero_de_mandatos) - 1))
  
  return(mandatos_cargos)
}

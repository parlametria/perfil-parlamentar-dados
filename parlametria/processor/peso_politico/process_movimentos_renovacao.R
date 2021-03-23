library(tidyverse)
library(here)

#' @title Processa Movimentos de renovação
#' @description Recupera parlamentares que participaram de movimentos de renovação
#' @return Dataframe contendo lista de parlamentares que participaram de movimentos de renovação
process_movimentos_renovacao <- function() {
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
  
  return(movimentos_renovacao)
}

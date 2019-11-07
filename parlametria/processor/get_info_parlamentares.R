#' @title Recupera lista de parlamentares em exercício e informações individuais dos mesmos
#' @description Recupera informações dos deputados e senadores em exercício
#' @return Dataframe contendo informações dos parlametares (deputados e senadores) em exercício
#' @examples
#' parlamentares_exercicio <- get_info_parlamentares_em_exercicio()
get_info_parlamentares_em_exercicio <- function() {
  library(tidyverse)
  library(here)
  library(eeptools)
  
  parlamentares <- read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c"))
  
  parlamentares_exercicio <- parlamentares %>%    
    filter(em_exercicio == 1) %>% 
    mutate(data = lubridate::ymd(data_nascimento)) %>% 
    mutate(idade_completa = eeptools::age_calc(data, Sys.Date(), unit = "years")) %>% 
    mutate(idade = floor(idade_completa)) %>% 
    select(id, casa, nome_eleitoral, sg_partido, uf, genero, idade)
    
  return(parlamentares_exercicio)
}

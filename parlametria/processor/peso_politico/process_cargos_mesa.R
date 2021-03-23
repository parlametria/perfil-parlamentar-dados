library(tidyverse)
library(here)
source(here("parlametria/crawler/cargos_mesa/fetcher_cargos_mesa.R"))

#' @title Processa Cargos na Mesa Diretora
#' @description Recupera parlamentares e o índice de cargos ocupados na Mesa Diretora
#' @return Dataframe contendo lista de parlamentares e o índice/peso de cargos ocupados na Mesa Diretora
process_cargos_mesa <- function() {
  cargos_mesa_camara <- fetch_cargos_mesa_camara(legislatura = 56, atual_cargo = TRUE) %>% 
    mutate(casa = "camara")
  
  cargos_mesa_senado <- fetch_cargos_mesa_senado() %>% 
    mutate(casa = "senado")
  
  cargos_mesa <- cargos_mesa_camara %>% 
    rbind(cargos_mesa_senado) %>% 
    mutate(id = as.character(id)) %>% 
    mutate(indice_cargo_mesa = case_when(
      str_detect(cargo, "Suplente de Secretário") ~ 0,
      str_detect(cargo, "Secretário") ~ 3,
      str_detect(cargo, "Vice-Presidente") ~ 1,
      str_detect(cargo, "Presidente") ~ 7,
      TRUE ~ 0)) %>% 
    mutate(indice_cargo_mesa = indice_cargo_mesa / max(indice_cargo_mesa)) %>% 
    select(id, casa, indice_cargo_mesa)
  
  return(cargos_mesa)
}
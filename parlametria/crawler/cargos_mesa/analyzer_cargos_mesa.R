#' @title Recupera e processa os dados sobre cargos da Mesa Diretora
#' @description Recupera e processa os dados de cargos na Mesa Diretora para a Câmara dos Deputados e Senado Federal.
#' @return Dataframe contendo parlamentares com cargos na Mesa da Câmara.
#' @examples
#' parlamentares_cargos <- processa_cargos_mesa()
processa_cargos_mesa <- function() {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/cargos_mesa/fetcher_cargos_mesa.R"))
  
  cargos_mesa <-fetch_cargos_mesa_camara() %>% 
    rbind(fetch_cargos_mesa_senado()) %>% 
    select(id_parlamentar = id, casa, cargo, data_inicio, data_fim, legislatura)
  
  source(here::here("parlametria/crawler/cargos_mesa/constants.R"))
  
  cargos_mesa_alt <- cargos_mesa %>% 
    mutate(
      cargo = dplyr::case_when(
        str_detect(tolower(cargo), tolower(.VICE_PRESIDENTE_1)) ~ "Primeiro Vice-presidente",
        str_detect(tolower(cargo), tolower(.VICE_PRESIDENTE_2)) ~ "Segundo Vice-presidente",
        str_detect(tolower(cargo), tolower(.PRESIDENTE)) ~ "Presidente",
        str_detect(tolower(cargo), tolower(.SECRETARIO_1)) ~ "Primeiro Secretário",
        str_detect(tolower(cargo), tolower(.SECRETARIO_2)) ~ "Segundo Secretário",
        str_detect(tolower(cargo), tolower(.SECRETARIO_3)) ~ "Terceiro Secretário",
        str_detect(tolower(cargo), tolower(.SECRETARIO_4)) ~ "Quarto Secretário",
        str_detect(tolower(cargo), tolower(.SUPLENTE_SECRETARIO_1)) ~ "Primeiro Suplente de Secretário",
        str_detect(tolower(cargo), tolower(.SUPLENTE_SECRETARIO_2)) ~ "Segundo Suplente de Secretário",
        str_detect(tolower(cargo), tolower(.SUPLENTE_SECRETARIO_3)) ~ "Terceiro Suplente de Secretário",
        str_detect(tolower(cargo), tolower(.SUPLENTE_SECRETARIO_4)) ~ "Quarto Suplente de Secretário",
        str_detect(tolower(cargo), tolower(.SUPLENTE_1)) ~ "Primeiro Suplente",
        str_detect(tolower(cargo), tolower(.SUPLENTE_2)) ~ "Segundo Suplente",
        str_detect(tolower(cargo), tolower(.SUPLENTE_3)) ~ "Terceiro Suplente",
        str_detect(tolower(cargo), tolower(.SUPLENTE_4)) ~ "Quarto Suplente"
      )
    ) 
  return(cargos_mesa_alt)
  
}
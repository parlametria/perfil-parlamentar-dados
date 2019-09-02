processa_frentes <- function(ids_frentes_df = readr::read_csv(here::here("crawler/raw_data/frentes/ids_frentes.csv"))) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/frentes/fetcher_frentes.R"))
  
  frentes <- purrr::map2_df(ids_frentes_df$id, "camara", ~fetch_frente(.x, .y))
  membros <- purrr::map2_df(ids_frentes_df$id, "camara", ~fetch_membros_frente(.x, .y))
  
  return(list(frentes, membros))
}

#' @title Recupera informações das frentes e de seus membros
#' @description Retorna dados de frentes do Congresso Nacional e também seus membros
#' @return Lista com dois Dataframes: frentes e de membros das frentes
#' @examples
#' processa_frentes_membros()
processa_frentes_membros <- function() {
  library(tidyverse)
  
  dados_frentes <- processa_frentes()
  
  frentes <- dados_frentes[[1]]
  membros_frentes <- dados_frentes[[2]]
  
  return(list(frentes, membros_frentes))
}

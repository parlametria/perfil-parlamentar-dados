processa_frentes <- function(ids_frentes_df = readr::read_csv(here::here("crawler/raw_data/frentes/ids_frentes.csv"))) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/frentes/fetcher_frentes.R"))
  
  frentes <- purrr::map2_df(ids_frentes_df$id, "camara", ~fetch_frente(.x, .y))
  membros <- purrr::map2_df(ids_frentes_df$id, "camara", ~fetch_membros_frente(.x, .y))
  
  return(list(frentes, membros))
}
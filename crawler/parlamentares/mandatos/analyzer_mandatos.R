#' @title Extrai informações sobre o mandato de um parlamentar
#' @description Recebe o id e a casa de um parlamentar e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param id_parlamentar id do parlamentar
#' @param casa casa do parlamentar
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_mandatos(141428, "camara")
extract_mandatos <- function(id_parlamentar, casa) {
  print(paste0("Baixando informações de mandatos do parlamentar de id ", id_parlamentar, " na casa ", casa, "..."))
  if (tolower(casa) == 'camara') {
    source(here::here("crawler/parlamentares/mandatos/fetcher_mandatos_camara.R"))
    return(extract_mandatos_camara(id_parlamentar))
  } else {
    source(here::here("crawler/parlamentares/mandatos/fetcher_mandatos_senado.R"))
    return(extract_mandatos_senado(id_parlamentar))
  }
}

#' @title Extrai informações sobre os mandato de todos os parlamentares
#' @description Recebeum dataframe contendo id e casa dos parlamentares e retorna um dataframe contendo informações do mandato, como legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @param df_parlamentares dataframe com informações de id e casa dos parlamentares
#' @return Dataframe contendo informações de legislatura,
#' data de inicio, data de fim, situacao, código e descrição da causa do fim do exercício.
#' @examples
#' extract_all_mandatos(readr::read_csv(here::here("crawler/raw_data/parlamentares.csv")))
extract_all_mandatos <- function(df_parlamentares = readr::read_csv(here::here("crawler/raw_data/parlamentares.csv"))) {
  library(tidyverse)
  
  mandatos <-
    purrr::map2_df(df_parlamentares$id, df_parlamentares$casa, 
                   ~ extract_mandatos(.x, .y)) %>% 
    distinct()
  return(mandatos)
}
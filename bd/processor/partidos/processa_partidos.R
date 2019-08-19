#' @title Processa dados dos partidos
#' @description Processa os dados dos partidos políticos
#' @param partidos_path Caminho para o arquivo de dados dos partidos
#' @return Dataframe com informações de partidos
processa_partidos <- function(partidos_path = here::here("crawler/raw_data/partidos.csv")) {
  partidos <- readr::read_csv(partidos_path)
  
  return(partidos)
}
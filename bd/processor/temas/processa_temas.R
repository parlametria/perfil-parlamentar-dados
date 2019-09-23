#' @title Cria dados dos temas
#' @description Cria os dados dos temas
#' @return Dataframe com informações dos temas (descrição e id)
processa_temas <- function() {
  source(here::here("crawler/proposicoes/process_proposicao_tema.R"))
  temas <- processa_temas_proposicoes()
  
  return(temas)
}
#' @title Processa os dados sobre os grupos econômicos das empresas no formato do banco de dados
#' @description Gera um datafrane contendo id e grupo de atividade econômica.
#' @return Dataframe com identificador e grupo de atividade econômica.
processa_atividade_economica <- function() {
  library(here)
  source(here("parlametria/processor/empresas/processa_empresas.R"))
  
  grupos_atividade_economica <- process_atividade_economica()
  
  return(grupos_atividade_economica)
}

#' @title Processa os dados sobre as empresas
#' @description Retorna um dataframe contendo informações sobre empresas no formato do BD.
#' @return Dataframe com dados processados de empresas
processa_empresas <- function() {
  library(here)
  source(here("parlametria/processor/empresas/processa_empresas.R"))
  
  empresas <- process_empresas()
  
  return(empresas)
  
}
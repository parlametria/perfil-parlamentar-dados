#' @title Baixa informações de empresas em batches
#' @description Recebe um conjunto de dados de sócios de empresas que são doadores, divide esse conjunto em partes
#' menores, baixa informações e retorna um conjunto de dados com os dados da empresa.
#' @param socios_empresas_doadores Dataframe com dados de doadores de campanhas que são sócios de empresas (
#' Resultado da função filter_socios_empresas_doadores() em analyzer_socios_empresas_agricolas_doadores_campanha.R)
#' @param somente_agricolas Flag para indicar se o filtro de agrícolas deve ser aplicado
#' @return Dataframe das empresas que possuem sócios doadores de campanha
fetcher_socios_empresas_fragmentado <-
  function(socios_empresas_doadores,
           somente_agricolas = FALSE) {
    library(tidyverse)
    library(here)
    source(
      here(
        "parlametria/crawler/empresas/socios_empresas/doadores_campanha/fetcher_socios_empresas_doadores_campanha.R"
      )
    )
    
    nrow_socios = nrow(socios_empresas_doadores)
    batch_size = 8000
    
    reparticoes <- split(
      socios_empresas_doadores,
      rep(
        1:ceiling(nrow_socios / batch_size),
        each = batch_size,
        length.out = nrow_socios
      )
    )
    
    # Cria, se não existe, o diretório para armazenar os dataframes intermediários
    dir.create(file.path(here("parlametria/raw_data/empresas"), "socios_empresas"), showWarnings = FALSE)
    
    purrr::map(seq(1:length(reparticoes)), function(x) {
      print(paste0("Baixando batch número ", x))
      df <- fetch_socios_empresas_doadores(reparticoes[[x]], somente_agricolas)
      write_csv(df, paste0(
        here("parlametria/raw_data/empresas/socios_empresas/"),
        "socios_empresas_parte_",
        x,
        ".csv"
      ))
    })
    
  }

#' @title Baixa informações de empresas em batches
#' @description Recebe um dataframe com os sócios de empresas que são doadores de campanha 
#' e baixa as informações sobre as empresas agrícolas, dividindo o 
#' processamento em batches e depois reunindo os dados em um dataframe, que é retornado pela função.
#' @param socios_empresas_doadores Dataframe com dados de doadores de campanhas que são sócios de empresas (
#' Resultado da função filter_socios_empresas_doadores() em analyzer_socios_empresas_agricolas_doadores_campanha.R)
#' @param somente_agricolas Flag para indicar se o filtro de agrícolas deve ser aplicado
#' @return Dataframe das empresas agrícolas que possuem sócios doadores de campanha
process_socios_empresas_fragmentado <- function(socios_empresas_doadores, somente_agricolas = FALSE) {
  library(tidyverse)
  library(here)

  # fetcher_socios_empresas_fragmentado(socios_empresas_doadores, somente_agricolas)
  
  datapaths <-
    list.files(
      here("parlametria/raw_data/empresas/socios_empresas/"),
      pattern = "socios_empresas_parte_.*.csv",
      full.names = TRUE
    )
  
  socios_empresas_agricolas <- purrr::map_df(datapaths, ~ read_csv(.x, col_types = cols(.default = "c")))
  
  return(socios_empresas_agricolas)
}

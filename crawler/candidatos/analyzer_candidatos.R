#' @title Recupera dados de candidato de uma UF, conjunto de cargos e ano.
#' @description A partir de uma UF, um vetor de cargos e um ano específico, importa os dados dos candidatos extraídos no TSE.
#' @param uf UF (unidade federativa) que se refere ao arquivo específico que será lido.
#' @param folder_path caminho para o diretório que contém os diretórios por ano com os dados do TSE para os candidatos.
#' @param cargos Vetor com os códigos dos cargos para filtragem dos candidatos.
#' @param ano Ano da eleição.
#' @return Dataframe
#' contendo ano da eleição, cpf do candidato, código do cargo, descrição do cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- import_candidatos_uf(uf = "PB", folder_path = "./candidatos/", cargos = c(6), ano = 2018)
import_candidatos_uf <- function(uf, folder_path, cargos, ano) {
  library(tidyverse)
  source(here::here("crawler/candidatos/import_data_candidatos.R"))
  
  extension = ".csv"
  
  if (ano == 2010) {
    extension = ".txt"
  }
  
  path <- paste0(folder_path, "consulta_cand_", ano, "/consulta_cand_", ano, "_", uf, extension)
  
  candidatos_uf <- import_candidatos(path, ano) %>% 
    filter(cod_cargo %in% cargos)
  
  return(candidatos_uf)
}

#' @title Recupera dados de candidatos de um conjunto de UFs, considerando um conjunto de cargos e o ano da eleição.
#' @description A partir de uma UF, um vetor de cargos e um ano específico, importa os dados dos candidatos extraídos no TSE.
#' @param ano Ano da eleição.
#' @param ufs conjunto de UFs (vetor).
#' @param folder_path caminho para o diretório que contém os diretórios por ano com os dados do TSE para os candidatos.
#' @param cargos Vetor com os códigos dos cargos para filtragem dos candidatos.
#' @return Dataframe
#' contendo uf, ano da eleição, cpf do candidato, código do cargo, descrição do cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- join_data_ufs(ano = 2018, ufs = c("PB", "SP), cargos = c(6), folder_path = "./candidatos/")
join_data_ufs <- function(ano, ufs, cargos, folder_path) {
  library(tidyverse)
  
  candidatos <- tibble::tibble(uf = ufs) %>%
    mutate(dados = purrr::map(
      uf,
      import_candidatos_uf,
      folder_path = folder_path,
      cargos = cargos,
      ano = ano
    )) %>% 
    unnest(dados)
  
  return(candidatos)
}

#' @title Processa dados de candidatos em eleições passadas
#' @description Recupera os dados dos candidatos a partir da base de dados do TSE
#' @param anos Vetor com os anos para recuperação da informação dos candidatos
#' @param cargos Vetor com os códigos dos cargos para filtragem dos candidatos.
#' @return Dataframe
#' contendo uf, ano da eleição, cpf do candidato, código do cargo, descrição do cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- export_data_candidatos(anos = c(2010, 2014, 2018), cargos = c(6))
processa_dados_candidatos <- function(anos, cargos){
  library(tidyverse)
  library(here)
  
  ufs <- c("AC" , "AL" , "AM" , "AP" , "BA" , "BR", "CE", "DF", "ES" , "GO" , "MA" , "MG" , "MS" , "MT" , "PA" , "PB" , "PE" , "PI" , "PR" , "RJ" , "RN" , "RO" , "RR" , "RS" , "SC" , "SE" , "SP" , "TO")

  candidatos <- tibble::tibble(ano = anos) %>%
    mutate(dados = purrr::map(
      ano,
      join_data_ufs,
      ufs,
      cargos = cargos,
      folder_path = here::here("crawler/candidatos/")
      )) %>% 
    unnest(dados) %>% 
    select(-ano)
  
  return(candidatos)
}
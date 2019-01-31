#' @title Recupera dados de candidato de uma UF, conjunto de cargos e ano.
#' @description A partir de uma UF, um vetor de cargos e um ano específico, importa os dados dos candidatos extraídos no TSE.
#' @param uf UF (unidade federativa) que se refere ao arquivo específico que será lido.
#' @param folder_path caminho para o diretório que contém os diretórios por ano com os dados do TSE para os candidatos.
#' @param cargos Vetor com os códigos dos cargos para filtragem dos candidatos.
#' @param ano Ano da eleição.
#' @param complete Se TRUE retorna informações mais completas sobre os candidatos (mais colunas). FALSE por default.
#' @return Dataframe
#' contendo, se complete = FALSE ano da eleição, cpf do candidato, código do cargo, descrição do cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- import_candidatos_uf(uf = "PB", folder_path = "./candidatos/", cargos = c(6), ano = 2018)
#' candidatos <- import_candidatos_uf(uf = "PB", folder_path = "./candidatos/", cargos = c(6), ano = 2018, complete = TRUE)
import_candidatos_uf <- function(uf, folder_path, cargos, ano, complete = FALSE) {
  library(tidyverse)
  source(here::here("crawler/candidatos/import_data_candidatos.R"))
  
  extension = ".csv"
  
  if (ano == 2010) {
    extension = ".txt"
  }
  
  path <- paste0(folder_path, "consulta_cand_", ano, "/consulta_cand_", ano, "_", uf, extension)
  
  candidatos_uf <- import_candidatos(path, ano, complete) %>% 
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
#' candidatos <- processa_dados_candidatos(anos = c(2010, 2014, 2018), cargos = c(6))
processa_dados_candidatos <- function(anos, cargos){
  library(tidyverse)
  library(here)
  
  ufs <- c("AC" , "AL" , "AM" , "AP" , "BA" , "BR", "CE", "DF", "ES" , "GO" , "MA" , "MG" , 
           "MS" , "MT" , "PA" , "PB" , "PE" , "PI" , "PR" , "RJ" , "RN" , "RO" , "RR" , "RS" , 
           "SC" , "SE" , "SP" , "TO")

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

#' @title Processa dados de candidatos a deputado federal nas eleições de 2018.
#' @description Recupera os dados dos candidatos em 2018 a partir da base de dados do TSE e retorna informações detalhadas sobre os mesmos.
#' @return Dataframe
#' contendo "uf", "estado", "nome_candidato", "nome_urna", "nome_social", "email", "tipo_agremiacao", "num_partido", "sg_partido",           "partido"             
#' "nome_coligacao", "composicao_coligacao", "idade_posse", "genero", "grau_instrucao", "raca", "ocupacao", "cpf", "reeleicao", "nome_exibicao"
#' @examples
#' candidatos <- processa_info_candidatos_2018()
processa_info_candidatos_2018 <- function() {
  library(tidyverse)
  library(here)
  
  ufs <- c("AC" , "AL" , "AM" , "AP" , "BA" , "BR", "CE", "DF", "ES" , "GO" , "MA" , "MG" , 
           "MS" , "MT" , "PA" , "PB" , "PE" , "PI" , "PR" , "RJ" , "RN" , "RO" , "RR" , "RS" , 
           "SC" , "SE" , "SP" , "TO")
  
  candidatos <- tibble::tibble(uf = ufs) %>%
    dplyr::mutate(dados = purrr::map(
      uf,
      import_candidatos_uf,
      folder_path = here::here("crawler/candidatos/"),
      cargos = c(6),
      ano = 2018,
      complete = TRUE
    )) %>% 
    unnest(dados)
  
  candidatos_alt <- candidatos %>% 
    dplyr::mutate(reeleicao = dplyr::if_else(situacao_reeleicao == "S", 1, 0)) %>% 
    dplyr::mutate(nome_exibicao = dplyr::if_else(nome_social_candidato != "#NULO#", nome_social_candidato, nome_candidato)) %>% 
    dplyr::select(uf = sigla_UF, estado = desc_unid_eleitoral, nome_candidato, nome_urna = nome_urna_candidato, 
                  nome_social = nome_social_candidato, email, tipo_agremiacao, num_partido = numero_partido,
                  sg_partido = sigla_partido, partido = nome_partido, nome_coligacao = nome_legenda, 
                  composicao_coligacao = composicao_legenda, idade_posse = idade_cand_data_eleicao, genero = desc_genero, 
                  grau_instrucao = desc_grau_instrucao, raca = desc_cor_raca, ocupacao = desc_ocupacao, cpf = cpf_candidato,
                  reeleicao, nome_exibicao)
  
  return(candidatos_alt)
}

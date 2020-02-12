#' @title Recupera os cpfs dos senadores
#' @description Recebe um caminho para o dataset de candidatos e o dataset de parlamentares, e une os parlamentares com os
#' dados da eleição a fim de extrair o CPF para os senadores.
#' @param candidatos_data_path Caminho para o dataframe com dados de candidatos
#' @param parlamentares Dataframe com dados de parlamentares
#' @return Dataframe contendo id e CPF dos senadores
process_cpf_parlamentares_senado <- function(
  parlamentares = readr::read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")),
  candidatos_2018_data_path = here::here("parlametria/raw_data/dados_tse/consulta_cand_2018_BRASIL.csv.zip"),
  candidatos_2014_data_path = here::here("parlametria/raw_data/dados_tse/consulta_cand_2014_BRASIL.csv.zip")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/utils/utils.R"))
  
  candidatos_2018 <- read_delim(candidatos_2018_data_path, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                                locale = locale(encoding = 'latin1'))
  
  candidatos_2014 <- read_delim(candidatos_2014_data_path, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                                locale = locale(encoding = 'latin1'))
  
  candidatos <- candidatos_2018 %>% 
    rbind(candidatos_2014) %>% 
    mutate(DS_CARGO = str_to_title(DS_CARGO)) %>% 
    mutate(NM_CANDIDATO = gsub("-", " ", NM_CANDIDATO)) %>% 
    filter(DS_CARGO %in% c("Senador", "1º Suplente", "2º Suplente")) %>% 
    select(NM_CANDIDATO, NR_CPF_CANDIDATO)
  
  parlamentares <- parlamentares %>% 
    select(id, nome_civil)
  
  senadores_com_cpf <- parlamentares %>% 
    mutate(nome_padronizado = padroniza_nome(nome_civil)) %>% 
    inner_join(candidatos %>% 
                 mutate(nome_padronizado = padroniza_nome(NM_CANDIDATO)), 
               by = c("nome_padronizado")) %>% 
    select(id, 
           cpf = NR_CPF_CANDIDATO,
           nome_civil)
  
  return(senadores_com_cpf)
}

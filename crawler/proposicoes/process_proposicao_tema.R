#' @title Retorna o id de um tema dado sem nome
#' @description A partir do nome do tema retorna seu id
#' @param tema_nome Nome do tema
#' @return Inteiro com o id do tema
#' @examples
#' tema_id <- getIdfromTema("Meio Ambiente")
getIdfromTema <- function(tema_nome) {
  library(tidyverse)
  
  tema_id <- case_when(
    tolower(tema_nome) == tolower("Meio Ambiente") ~ 0,
    tolower(tema_nome) == tolower("Direitos Humanos") ~ 1,
    tolower(tema_nome) == tolower("Integridade e Transparência") ~ 2,
    tolower(tema_nome) == tolower("Agenda Nacional") ~ 3,
    tolower(tema_nome) == tolower("Educação") ~ 5,
    TRUE ~ 99
  )
  
  return(tema_id)
}

#' @title Retorna as proposições votadas em plenários e seus temas 
#' (mais de uma observação por proposição se houver mais de uma tema para a proposição)
#' @description IDs dos temas das proposições
#' @param url URL para os dados de proposições votadas na legislatura atual
#' @return Dataframe com proposições e os temas (ids)
#' @examples
#' proposicoes_temas <- process_proposicoes_plenario_selecionadas_temas(url)
process_proposicoes_plenario_selecionadas_temas <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSvvT0fmGUMwOHnEPe9hcAMC_l-u9d7sSplNYkMMzgiE_vFiDcWXWwl4Ys7qaXuWwx4VcPtFLBbMdBd/pub?gid=399933255&single=true&output=csv") {
  library(tidyverse)
  
  proposicoes <- read_csv(url, col_types = cols(id = "c"))
  
  proposicoes_va <- proposicoes %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    mutate(tema = strsplit(as.character(tema_va), ";")) %>% 
    unnest(tema) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(tema_id = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    distinct(id_proposicao = id, tema_id)
  
  return(proposicoes_va)
}

process_proposicoes_questionario_temas <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTMcbeHRm_dqX-i2gNVaCiHMFg6yoIjNl9cHj0VBIlQ5eMX3hoHB8cM8FGOukjfNajWDtfvfhqxjji7/pub?gid=0&single=true&output=csv") {
  library(tidyverse)
  
  proposicoes <- read_csv(url, col_types = cols(id_proposicao = "c"))
  
  proposicoes_va <- proposicoes %>% 
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>% 
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    select(-n_prop) %>% 
    mutate(tema = strsplit(as.character(tema), ";")) %>% 
    unnest(tema) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(tema_id = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    distinct(id_proposicao, tema_id)
    
  return(proposicoes_va)
}

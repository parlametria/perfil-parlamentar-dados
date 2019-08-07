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
process_proposicoes_plenario_selecionadas_temas <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_CAMARA
  }
  
  proposicoes <- read_csv(url, col_types = cols(id = "c"))
  
  proposicoes_va <- proposicoes %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    mutate(tema = strsplit(as.character(tema_va), ";")) %>% 
    unnest(tema) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(id_tema = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    mutate(id_proposicao = id) %>% 
    distinct(id_proposicao, id_tema)
  
  return(proposicoes_va)
}

process_proposicoes_questionario_temas <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_VOZATIVA
  }
  
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

#' @title Cria dados dos temas
#' @description Cria os dados dos temas
#' @return Dataframe com informações dos temas (descrição e id)
processa_temas_proposicoes <- function() {
  temas <- data.frame(id_tema = c(0, 1, 2, 3, 5, 99),
                      tema = c("Meio Ambiente", 
                               "Direitos Humanos", 
                               "Integridade e Transparência", 
                               "Agenda Nacional", 
                               "Educação",
                               "Geral"), 
                      slug = c("meio-ambiente",
                               "direitos-humanos",
                               "transparencia",
                               "agenda-nacional",
                               "educacao",
                               "geral"),
                      ativo = c(1, 1, 1, 1, 1, 0),
                      stringsAsFactors = FALSE)
  
  return(temas)
}
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
    TRUE ~ 101
  )
  
  return(tema_id)
}

#' @title Retorna o id de um tema dado sem nome, a partir de uma lista de temas previamente selecionados
#' @description A partir do nome do tema retorna seu id
#' @param tema_nome Nome do tema
#' @param temas Lista contendo todos os temas selecionados
#' @return Inteiro com o id do tema
getIdfromListaTema <- function(tema_nome, temas) {
  library(tidyverse)
  
  tema_nome <- tolower(tema_nome)
  
  tema_id <- 
  if(tema_nome %in% sapply(temas$tema, tolower)) {
    as.numeric(temas %>% filter(tolower(tema) == tema_nome) %>% pull(id_tema))
  } else {
    101
  }
  
  return(tema_id)
}

#' @title Retorna as proposições selecionadas votadas em plenários e seus temas 
#' (mais de uma observação por proposição se houver mais de uma tema para a proposição)
#' @description IDs dos temas das proposições selecionadas
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

#' @title Retorna as todas as proposições votadas em plenários e seus temas 
#' (mais de uma observação por proposição se houver mais de uma tema para a proposição)
#' @description IDs dos temas das proposições
#' @param proposicoes dataframe contendo todas proposicoes de interesse
#' @param casa_aderencia determina qual casa deseja adquirir os temas
#' @return Dataframe com proposições e os temas (ids)
process_proposicoes_plenario_temas <- function(proposicoes = NULL, casa_aderencia = "camara") {
  if (is.null(proposicoes)) {
    source(here("crawler/proposicoes/analyzer_proposicoes.R"))
    proposicoes <- fetch_proposicoes(selecionadas = 0, casa_aderencia)
  }
  
  source(here("crawler/proposicoes/fetcher_proposicao_info.R"))
  
  temas <- processa_temas_proposicoes()
  
    if(casa_aderencia == "camara") {
      proposicoes_va <- proposicoes %>% 
      mutate(tema = map_chr(id_proposicao, fetch_apenas_tema_proposicao)) %>%
      mutate(tema = strsplit(as.character(tema), ";")) %>%
      unnest(tema) %>%
      ungroup() %>%
      rowwise() %>% 
      mutate(id_tema = getIdfromListaTema(tema, temas)) %>%
      ungroup() %>%
      mutate(id_proposicao = id_proposicao) %>%
      distinct(id_proposicao, id_tema)
    } else {
      proposicoes_va <- proposicoes %>% 
      mutate(tema = map_chr(id_proposicao, fetch_tema_proposicoes_senado)) %>%
      mutate(tema = strsplit(as.character(tema), ";")) %>%
      unnest(tema) %>%
      ungroup() %>%
      rowwise() %>%
      mutate(id_tema = getIdfromListaTema(tema, temas)) %>%
      ungroup() %>%
      mutate(id_proposicao = id_proposicao) %>%
      distinct(id_proposicao, id_tema)
    }
  
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
    mutate(id_tema = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    distinct(id_proposicao, id_tema)
    
  return(proposicoes_va)
}

#' @title Cria dados dos temas
#' @description Cria os dados dos temas
#' @return Dataframe com informações dos temas (descrição e id)
processa_temas_proposicoes <- function() {
  library(tidyverse)
  
  temas <- read_csv(file = "crawler/proposicoes/temas/temas.csv", col_types = cols(col_number(), col_character(), col_character(), col_number()))

  return(temas)
}

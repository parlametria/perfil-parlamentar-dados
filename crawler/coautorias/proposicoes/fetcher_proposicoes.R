#' @title Recupera informações dos temas das proposições de um ano
#' @description A partir do ano, recupera todos os temas das proposições
#' @param ano Ano
#' @return Dataframe contendo informações dos temas das proposições por ano
#' @examples
#' propositions_temas <- .fetch_tema_proposicoes(2019)
.fetch_tema_proposicoes <- function(ano = 2019) {
  library(tidyverse)
  
  url <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/csv/proposicoesTemas-", ano, ".csv")
  temas <-readr::read_delim(url, delim = ";")
  
  temas <- temas %>% 
    mutate(id = stringr::str_extract(uriProposicao, '\\d*$') %>% as.numeric()) %>% 
    group_by(id) %>% 
    summarise(tema = paste(unlist(tema), collapse = '; ')) %>% 
    mutate(ano = ano)
  
  return(temas)
}

#' @title Recupera informações dos temas para todas as proposições criadas na legislatura 56
#' @description Classifica por tema e lista proposições criadas na legislatura 56
#' @return Dataframe com lista de proposições e seus respectivos temas
#' @examples
#' proposicoes_temas <- fetch_propositions()
fetch_propositions <- function(initial_date = "2019-02-01") {
  library(tidyverse)
  
  url <-
    "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
  
  propositions <- readr::read_delim(url, delim = ";") %>%
    filter(dataApresentacao >= initial_date) %>%
    select(id, siglaTipo, numero, ano)
  
  ano = strsplit(initial_date, '-')[[1]][1]
  propositions_themes <- .fetch_tema_proposicoes(ano)
  
  propositions_ma <- propositions_themes %>%  
    unique() %>% 
    inner_join(propositions, by = "id")
  
  return(propositions_ma)
}

#' @title Recupera informações das proposições a partir dos anos de interesse
#' e tema
#' @description Retorna id e tema das proposições com base nos anos e tema passados
#' como parâmetro
#' @param anos Anos de interesse
#' @param tema_selecionado Tema selecionado
#' @return Dataframe com lista de proposições e seus respectivos temas
#' @examples
#' proposicoes_temas <- fetch_all_propositions_by_ano_e_tema()
fetch_all_propositions_by_ano_e_tema <- function(anos = c(2019, 2020), tema_selecionado = "Meio Ambiente") {
  props <- purrr::map_df(anos, ~ .fetch_tema_proposicoes(.x))
  
  props_filtered <- props %>% 
    filter(str_detect(tolower(tema), tolower(tema_selecionado)))
  
  return(props_filtered)
  
}
library(tidyverse)

processaProposicoesAutores <- function(df) {
  remove_autor_regex = 
    'comissão|instituto|associação|senado|tribunal|poder|sos|mesa|presidência'
  
  df <-
    df %>%
    filter(!stringr::str_detect(tolower(nomeAutor),
                                remove_autor_regex) &
             tipoAutor == 'Deputado') %>%
    select(id = idDeputadoAutor,
           id_req = idProposicao) %>% 
    mutate(
      id = as.character(id)) %>%
    distinct(id, id_req) %>%
    filter(!is.na(id))
  
  return(df)
}

exportaAutoresProposicoes <- function() {
  url <- 
    "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"
  
  df <- 
    readr::read_delim(url, delim = ";") %>% 
    processaProposicoesAutores()
}


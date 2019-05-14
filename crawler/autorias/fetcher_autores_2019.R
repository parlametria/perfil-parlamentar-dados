library(tidyverse)

getDadosFaltosos <- function(df) {
  df <-
    df %>% 
    filter(is.na(siglaPartidoAutor) | is.na(siglaUFAutor)) %>% 
    group_by(nomeAutor, idDeputadoAutor) %>% 
    distinct(nomeAutor)
  
  deputados <- purrr::map_df(df$idDeputadoAutor, ~ getDeputadoDados(.x))
  return(deputados)
}

getDeputadoDados <- function(id_deputado) {
  url <- 
    paste0('https://dadosabertos.camara.leg.br/api/v2/deputados/', id_deputado)
  
  Sys.sleep(5)
  
  dados <- tryCatch({
    data <- 
      RCurl::getURL(url) %>% 
      jsonlite::fromJSON() %>% 
      unlist() %>% t() %>% 
      as_tibble() %>% 
      select(
        siglaUFAutor = dados.ultimoStatus.siglaUf,
        siglaPartidoAutor = dados.ultimoStatus.siglaPartido)
    data$idDeputadoAutor = id_deputado
    return(data)
  }, error = function(e) {
    return(tribble(~ siglaUFAutor, ~ siglaPartidoAutor, ~ idDeputadoAtor))
  })
  
  return (dados)
}

processaProposicoesAutores <- function(df) {
  remove_autor_regex = 
    'comissão|instituto|associação|senado|tribunal|poder|sos|mesa|presidência'
  
  df <-
    df %>%
    filter(!stringr::str_detect(tolower(nomeAutor),
                                remove_autor_regex) &
             tipoAutor == 'Deputado') %>%
    left_join(getDadosFaltosos(.), by = "idDeputadoAutor") %>%
    mutate(
      siglaPartidoAutor = if_else(
        is.na(siglaPartidoAutor.x),
        siglaPartidoAutor.y,
        siglaPartidoAutor.x
      ),
      siglaUFAutor = if_else(is.na(siglaUFAutor.x),
                             siglaUFAutor.y,
                             siglaUFAutor.x)
    ) %>%
    select(id = idDeputadoAutor,
           id_req = idProposicao,
           nome = nomeAutor,
           partido = siglaPartidoAutor,
           uf = siglaUFAutor) %>% 
    mutate(id = as.character(id))
  
  return(df)
}

exportaAutoresProposicoes <- function(df, 
                                      outpath = here::here("crawler/raw_data/autores_proposicoes_2019.csv")) {
  
  df %>% 
    processaProposicoesAutores() %>% 
    write_csv(outpath)
}

url <- 
  "https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-2019.csv"

df <- 
  readr::read_delim(url, delim = ";") %>% 
  exportaAutoresProposicoes(df)

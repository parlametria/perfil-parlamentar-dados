library(networkD3)
library(tidyverse)
library(tidygraph)
library(ggraph)


getDadosFaltosos <- function(df) {
  df = 
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
  remove_autor_regex = 'comissão|instituto|associação|senado|tribunal|poder|sos|mesa|presidência'
  
  df <-
    read_delim(propositions_filepath,
               ";",
               escape_double = FALSE,
               trim_ws = TRUE) %>%
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
                             siglaUFAutor.x),
      nomeAutor =
        paste0(nomeAutor, ' - ',
               siglaPartidoAutor, '/', siglaUFAutor)
    ) %>%
    select(id_req = idProposicao,
           nome = nomeAutor,
           partido = siglaPartidoAutor)
  
  return(df)
}

generateNodes <- function(df) {
  nodes <- df %>% 
    dplyr::select(nome, id_req, partido) %>% 
    dplyr::group_by(nome, partido) %>% 
    dplyr::distinct() %>% 
    dplyr::summarise(size = n()) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(partido = as.factor(partido), nome = as.factor(nome)) %>% 
    tibble::rowid_to_column("index") %>% 
    dplyr::mutate(index = index - 1) %>% 
    dplyr::select(index, nome, partido) %>% 
    as.data.frame()
  
  return(nodes)
}

generateEdges <- function(df) {
  edges <- df %>% full_join(df, by = "id_req") %>%
    filter(nome.x != nome.y) %>% 
    dplyr::group_by(nome.x, nome.y) %>% 
    dplyr::mutate(source = first(nome.x), target = first(nome.y), value = n()) %>% 
    ungroup() %>% 
    mutate(source = as.factor(source), target = as.factor(target)) %>% 
    left_join(nodes %>% select(index, nome), by = c("source" = "nome")) %>% 
    left_join(nodes %>% select(index, nome), by = c("target" = "nome")) %>% 
    select(source = index.x, target = index.y, value) %>% 
    arrange(target) %>% 
    as.data.frame() %>% 
    removeDuplicatedEdges()
  
  return (edges)
}


generateGraph <- function(propositions_filepath = here::here("crawler/raw_data/proposicoesAutores-2019.csv"), 
                           output_file) {
  
  df <- processaProposicoesAutores(propositions_filepath)
  nodes <- generateNodes(df)
  links <- generateEdges(df)
  
  # Plot
  fn <- 
    forceNetwork(Links = links, Nodes = nodes,
                 Source = "source", Target = "target",
                 Value = "value", NodeID = "nome",
                 Group = "partido",
                 opacity = 0.8, zoom = T,
                 linkColour = "#f2efef")
  
  
  fn %>% 
    saveNetwork(output_file)
  
  return(fn)
}


pasteCols = function(x, y, sep = ":"){
  stopifnot(length(x) == length(y))
  return(lapply(1:length(x), function(i){paste0(sort(c(x[i], y[i])), collapse = ":")}) %>% unlist())
}

removeDuplicatedEdges <- function(df) {
  df %>% 
    mutate(
      col_pairs = 
        pasteCols(source, 
                  target, 
                  sep = ":")) %>% 
    group_by(col_pairs) %>%
    tidyr::separate(
      col = col_pairs, 
      c("source", 
        "target"), 
      sep = ":") %>% 
    group_by(source, target) %>% 
    distinct()
}

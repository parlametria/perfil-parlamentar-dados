library(networkD3)
library(tidyverse)
library(tidygraph)
library(ggraph)

generate_graph <- function(propositions_filepath = here::here("crawler/raw_data/proposicoesAutores-2019.csv"), 
                           output_file) {
  
  df <- processaProposicoesAutores(propositions_filepath)
  
  pre_nodes <- df %>% 
    dplyr::select(nome, id_req, descricaoTipo) %>% 
    dplyr::distinct(nome) %>% 
    tibble::rowid_to_column("index") %>% 
    #dplyr::mutate(index = index - 1) %>% 
    dplyr::select(index, nome) %>% 
    as.data.frame()
  
  pre_links <- df %>% full_join(df, by = "id_req") %>%
    filter(nome.x != nome.y) %>% 
   # dplyr::select(-c(prop_id.x, casa.x, prop_id.y, casa.y)) %>% 
    dplyr::group_by(nome.x, nome.y) %>% 
    dplyr::summarise(source = first(nome.x), target = first(nome.y), value = 1/n()) %>% 
    ungroup() %>% 
    mutate(source = as.factor(source), target = as.factor(target)) %>% 
    left_join(pre_nodes %>% select(index, nome), by = c("source" = "nome")) %>% 
    left_join(pre_nodes %>% select(index, nome), by = c("target" = "nome")) %>% 
    select(source = index.x, target = index.y, value) %>% 
    arrange(target) %>% 
    as.data.frame()
  
  graph <- tbl_graph(nodes = pre_nodes,
                     edges = pre_links, 
                     directed = F)
  
  pre_nodes <- graph %>% 
    mutate(group = as.factor(group_edge_betweenness())) %>% 
    as.data.frame()
  
  nodes <- df %>% 
    dplyr::select(nome, id_req, descricaoTipo) %>% 
    dplyr::group_by(nome) %>% 
    dplyr::distinct() %>% 
    dplyr::summarise(size = n()) %>% 
    dplyr::mutate(group = 1, nome = as.factor(nome)) %>% 
    tibble::rowid_to_column("index") %>% 
    #dplyr::mutate(index = index - 1) %>% 
    dplyr::select(index, nome, group) %>% 
    as.data.frame() %>% 
    dplyr::left_join(pre_nodes, by ="nome") %>% 
    select(-c(index.y, group.x), index = index.x, nome, group = group.y)
  
  links <- df %>% full_join(df, by = "id_req") %>%
    filter(nome.x != nome.y) %>% 
    #dplyr::select(-c(prop_id.x, casa.x, prop_id.y, casa.y)) %>% 
    dplyr::group_by(nome.x, nome.y) %>% 
    dplyr::summarise(source = first(nome.x), target = first(nome.y), value = 1/n()) %>% 
    ungroup() %>% 
    mutate(source = as.factor(source), target = as.factor(target)) %>% 
    left_join(nodes %>% select(index, nome), by = cs("source" = "nome")) %>% 
    left_join(nodes %>% select(index, nome), by = c("target" = "nome")) %>% 
    select(source = index.x, target = index.y, value) %>% 
    arrange(target) %>% 
    as.data.frame()
  
  # Plot
  fn <- forceNetwork(Links = links, Nodes = nodes,
                     Source = "source", Target = "target",
                     Value = "value", NodeID = "nome",
                     Group ="group",
                     opacity = 0.8, zoom = T,
                     linkColour = "#808080")
  
  
  fn %>% 
    saveNetwork(output_file)
  return(fn)
}

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
library(tidyverse)
source(here::here("scripts/generate-graph.R"))

getRelacionadas <- function(id) {
  url <-
    paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
           id,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id = as.character(id))   %>%
    select(id)
  
  return(ids_relacionadas)
}


generateAutoriasConjuntas <- function(id, min_peso) {
  
  ids_relacionadas <- getRelacionadas(id)
  
  if (nrow(ids_relacionadas) > 0) {
    ids_relacionadas <- ids_relacionadas %>% rbind(id)
  } else {
    ids_relacionadas <- dplyr::tribble(~id, id)
  }
  
  ids_relacionadas <- ids_relacionadas %>% 
    mutate(id = as.character(id))
  
  parlamentares <-
    read_csv(here::here("data/parlamentares.csv")) %>%
    mutate(nome_eleitoral = paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido) %>% 
    mutate(id = as.character(id))
  
  autorias <- analyzer_autores_proposicoes()[[1]] %>% 
    filter(min_peso <= peso_arestas) %>% 
      removeDuplicatedEdges() %>%
      distinct() %>%
      mutate(id_req = as.character(id_req))
    
    link_para_detalhes_camara <- 
      "https://www.camara.leg.br/proposicoesWeb/fichadetramitacao?idProposicao="
    
    match <-
      ids_relacionadas %>%
      inner_join(autorias, by = c("id" = "id_req")) %>%
      inner_join(parlamentares, by = c("id.x" = "id")) %>%
      inner_join(parlamentares, by = c("id.y" = "id")) %>%
      select(id,
             id.x,
             nome_eleitoral.x,
             id.y,
             nome_eleitoral.y,
             peso_arestas)
    
    nodes <- generateNodes(parlamentares %>%
                             filter(id %in% match$id.x |
                                      id %in% match$id.y))
    
    edges <- generateEdges(match %>% select(id, id.x, id.y, peso_arestas), nodes)
    
    match <- match %>% 
      mutate(
        url = paste0(
          link_para_detalhes_camara, 
          id),
        nome_eleitoral.y = 
          if_else(id.x == id.y,
                  '-',
                  nome_eleitoral.y),
        id.y = 
          if_else(id.x == id.y,
                  '-',
                  id.y))
    
    return(list(match, nodes, edges))
}

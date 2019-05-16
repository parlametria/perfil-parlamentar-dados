library(tidyverse)
source(here::here("crawler/autorias/generate-graph.R"))
source(here::here("crawler/autorias/analyzer-autorias.R"))

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
  
  parlamentares <-
    read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>%
    mutate(nome_eleitoral = paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido) %>% 
    mutate(id = as.character(id))
  
  autorias <- exportaAutoresProposicoes() %>% 
    group_by(idProposicao) %>% 
    mutate(peso_arestas = 1/n()) %>% 
    filter(min_peso <= peso_arestas) %>% 
    ungroup() %>% 
    select(id_req = idProposicao,
           id = idDeputadoAutor,
           peso_arestas)
  
    autorias <- autorias %>% 
      dplyr::full_join(autorias, by =c("id_req", "peso_arestas")) %>%
      filter(id.x != id.y) %>%
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
             peso_arestas) %>% 
      mutate(
        url = paste0(
          link_para_detalhes_camara, 
          id))
    
    nodes <- generateNodes(parlamentares %>%
                             filter(id %in% match$id.x |
                                      id %in% match$id.y))
    
    edges <- generateEdges(match %>% select(id, id.x, id.y, peso_arestas), nodes)
    
    return(list(match, nodes, edges))
}

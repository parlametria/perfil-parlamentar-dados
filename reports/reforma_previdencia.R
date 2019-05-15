library(tidyverse)
source(here::here("crawler/autorias/generate-graph.R"))
source(here::here("crawler/autorias/analyzer-autorias.R"))

id_reforma <- 2192459

url <-
  paste0(
    "https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
    id_reforma,
    '/relacionadas'
  )

a <- function() {
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id_req = as.character(id))   %>%
    select(id_req)
  
  m <- exportaAutoresProposicoes()  %>%
    mutate(id_req = as.character(id_req))
  
  teste <-
    ids_relacionadas %>%
    inner_join(m, by = c("id_req")) %>%
    full_join(m, by = c("id_req")) %>%
    filter(id.x != id.y) %>%
    removeDuplicatedEdges()
  
  proposicoes <- exportaProposicoes()
  
  parlamentares <-
    read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>%
    mutate(nome_eleitoral = paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido)
  
  pares_autorias <-
    read_csv(here::here("crawler/raw_data/pares_autorias.csv"))
  
  match <-
    ids_relacionadas %>%
    inner_join(pares_autorias, by = c("id" = "id_req")) %>%
    inner_join(parlamentares, by = c("id.x" = "id")) %>%
    inner_join(parlamentares, by = c("id.y" = "id")) %>%
    select(id,
           id.x,
           nome_eleitoral.x,
           id.y,
           nome_eleitoral.y,
           descricao,
           uri)
  
  nodes <- generateNodes(parlamentares %>%
                           filter(id %in% match$id.x | id %in% match$id.y))
  
  edges <- generateEdges(match %>% select(id, id.x, id.y), nodes)
  
  forceNetwork(
    Links = edges,
    Nodes = nodes,
    Source = "source",
    Target = "target",
    Value = "value",
    NodeID = "nome_eleitoral",
    Group = "group",
    opacity = 0.8,
    zoom = T,
    linkColour = "#808080"
  )
  
}

b <- function() {
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>%
    mutate(id = as.character(id))   %>%
    select(id)
  
  parlamentares <-
    read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>%
    mutate(nome_eleitoral = paste0(nome_eleitoral, " - ", sg_partido, "/", uf)) %>%
    select(id, nome_eleitoral, sg_partido)
  
  pares_autorias <-
    read_csv(here::here("crawler/raw_data/pares_autorias.csv")) %>% 
    mutate(id_req = as.character(id_req))
  
  match <-
    ids_relacionadas %>%
    inner_join(pares_autorias, by = c("id" = "id_req")) %>%
    inner_join(parlamentares, by = c("id.x" = "id")) %>%
    inner_join(parlamentares, by = c("id.y" = "id")) %>%
    select(id,
           id.x,
           nome_eleitoral.x,
           id.y,
           nome_eleitoral.y,
           descricao,
           uri)
  
  nodes <- generateNodes(parlamentares %>%
                           filter(id %in% match$id.x |
                                    id %in% match$id.y))
  
  edges <- generateEdges(match %>% select(id, id.x, id.y), nodes)
  
  forceNetwork(
    Links = edges,
    Nodes = nodes,
    Source = "source",
    Target = "target",
    Value = "value",
    NodeID = "nome_eleitoral",
    Group = "group",
    opacity = 0.8,
    zoom = T,
    
    linkColour = "#808080"
  )

}

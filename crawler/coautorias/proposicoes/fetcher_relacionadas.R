#' @title Recupera informações das proposições relacionadas a uma proposição
#' específica
#' @description Recebe um id e retorna as proposições relacionadas
#' @param id_prop ID da proposição
#' @return Dataframe com lista de proposições relacionadas
fetch_relacionadas <- function(id_prop) {
  print(paste0("Baixando proposições relacionadas a ", id_prop, "..."))
  url <-
    paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
           id_prop,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame()
  
  if (nrow(ids_relacionadas) == 0) {
    return(tribble(~ id, id_prop))
  } 
  
  return (ids_relacionadas %>% 
            select(id) %>% 
            rbind(id_prop))
  
  return(ids_relacionadas)
}

#' @title Recupera informações das proposições relacionadas a um conjunto de
#' proposições
#' @description Recebe uma lista de ids de proposições e retorna as 
#' proposições relacionadas
#' @param ids IDs das proposições
#' @return Dataframe com lista de proposições relacionadas
fetch_all_relacionadas <- function(ids) {
  relacionadas <- purrr::map_df(ids, ~ fetch_relacionadas(.x)) %>% 
    dplyr::distinct()
  
  return(relacionadas)
}
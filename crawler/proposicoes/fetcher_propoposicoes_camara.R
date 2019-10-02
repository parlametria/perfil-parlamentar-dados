#' @title Recupera informações das proposições relacionadas
#' @description Recebe um id e um ano e retorna as proposições relacionadas
#' @param id_prop id da proposição
#' @return Dataframe com lista de proposições relacionadas
#' @examples
#' proposicoes_temas <- fetch_relacionadas(2121442)
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

#' @title Recupera informações das proposições relacionadas para um conjunto de proposições e anos
#' @description Recebe um conjunto de ids e anos e retorna as proposições relacionadas
#' @param ids ids das proposições
#' @param anos anos de interesse
#' @return Dataframe com lista de proposições relacionadas
fetch_all_relacionadas <- function(ids) {
  relacionadas <- purrr::map_df(ids, ~ fetch_relacionadas(.x)) %>% 
    dplyr::distinct()
  
  return(relacionadas)
}

#' @title Recupera ids das proposições que foram autoradas por um deputado, em uma página da API e 
#' número de itens retornados
#' @description Recebe um id de deputado, um número de página e a quantidade de itens a retornar de
#' proposições autoradas por esse deputado
#' @param id_deputado id do deputado
#' @param pagina página da API que se deseja acessar
#' @param itens número de itens que se deseja retornar
#' @return Dataframe com lista de proposições criadas pelo deputado, na página e número de itens
#' selecionado.
fetch_proposicoes_por_autor_e_pagina <- function(id_deputado, pagina, itens=100) {
  library(tidyverse)
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes?idDeputadoAutor=", 
                id_deputado,
                "&pagina=",
                pagina,
                "&itens=",
                itens)
  
  proposicoes <- tryCatch({
    data <- 
      (RCurl::getURI(url) %>% 
         jsonlite::fromJSON())$dados
    
    data <- data %>% 
      select(id)
    
  }, error=function(e) {
    return(tribble(~ id))
  })
  
  return(proposicoes)
}

#' @title Recupera ids das proposições que foram autoradas por um deputado e 
#' número de itens retornados por página
#' @description Recebe um id de deputado e a quantidade de itens da paginação na API de
#' proposições autoradas por esse deputado
#' @param id_deputado id do deputado
#' @param itens número de itens que se deseja dividir em páginas (sendo 100 o máximo)
#' @return Dataframe com lista de proposições criadas pelo deputado.
fetch_proposicoes_por_autor <- function(id_deputado, itens = 100) {
  library(tidyverse)
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes?idDeputadoAutor=", 
                id_deputado,
                "&itens=",
                itens)
  
  proposicoes <- tryCatch({
    links <- (RCurl::getURI(url) %>% 
      jsonlite::fromJSON())$links
    
    num_pags <- links %>% 
      filter(rel == "last") %>% 
      pull(href) %>% 
      str_extract("&pagina=[\\d]*&") %>% 
      str_extract("[\\d]")
    
    paginas <- seq(1, num_pags)
    
    data <- 
      purrr::map_df(paginas, ~ fetch_proposicoes_por_autor_e_pagina(id_deputado, .x, itens))
    
  }, error=function(e) {
    return(tribble(~ id))
  })
    
  return(proposicoes)
}

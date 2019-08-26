fetch_empresas_por_pagina <- function(url, page) {
  print(paste0("Baixando dados de empresas da página ", page))
  url <- paste0(url, page)
  
  json <- (RCurl::getURI(url) %>% 
    jsonlite::fromJSON())$results
  
  return(json)
}

fetch_all_empresas <- function(socios_folderpath = here::here("crawler/parlamentares/empresas/socios/")) {
 
}
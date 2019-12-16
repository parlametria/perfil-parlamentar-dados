fetch_mp_propositions <- function(year = "2019") {
  library(tidyverse)
  library(RCurl)
  library(jsonlite)
  
  url_api <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes?siglaTipo=MPV&ano=%s&ordem=ASC&ordenarPor=id&pagina=1&itens=100"
  
  url <- url_api %>% 
    sprintf(year)
  
  links <- (getURL(url) %>% jsonlite::fromJSON())$links
  
  last_page <- links %>% 
    filter(rel == "last") %>% 
    pull(href) %>% 
    str_match("pagina=(.*?)&") %>% 
    tibble::as_tibble(.name_repair = c("universal")) %>% 
    pull(`...2`)
  
  propositions <- tibble(page = 1:as.numeric(last_page)) %>%
    mutate(data = map(
      page,
      fetch_propositions_by_page,
      year,
      as.numeric(last_page)
    )) %>% 
    unnest(data)
}

fetch_propositions_by_page <- function(page = 1, year = "2019", last_page = 287) {
  library(tidyverse)
  library(RCurl)
  library(jsonlite)
  library(rcongresso)
  
  print(paste0("Downloading page ", page, "/", last_page))
  url_api <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes?siglaTipo=MPV&ano=%s&ordem=ASC&ordenarPor=id&pagina=%s&itens=100"
  
  url <- url_api %>% 
    sprintf(year, page)
  
  data <- (getURL(url) %>% jsonlite::fromJSON())$dados %>% 
    select(-uri)
  
  return(data)
}

fetch_tramited_propositions <- function(initial_date = "2019-02-01", final_date = Sys.Date()) {
  library(tidyverse)
  library(RCurl)
  library(jsonlite)
  
  url_api <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes?dataInicio=%s&dataFim=%s&ordem=ASC&ordenarPor=id&pagina=1&itens=100"
  
  url <- url_api %>% 
    sprintf(initial_date, final_date)
  
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
      initial_date,
      final_date,
      as.numeric(last_page)
    )) %>% 
    unnest(data)
}

fetch_propositions_by_page <- function(page = 1, initial_date = "2017-01-01", final_date = "2018-12-31", last_page = 287) {
  library(tidyverse)
  library(RCurl)
  library(jsonlite)
  
  print(paste0("Downloading page ", page, "/", last_page))
  url_api <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes?dataInicio=%s&dataFim=%s&ordem=ASC&ordenarPor=id&pagina=%s&itens=100"
  
  url <- url_api %>% 
    sprintf(initial_date, final_date, page)
  
  data <- (getURL(url) %>% jsonlite::fromJSON())$dados %>% 
    select(-uri)
  
  return(data)
}


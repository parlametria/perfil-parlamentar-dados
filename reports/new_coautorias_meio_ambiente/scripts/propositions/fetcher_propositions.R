fetch_propositions_from_2019 <- function(initial_date = "2019-02-01", final_date = Sys.Date()) {
  library(tidyverse)
  
  url <- "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
  
  propositions <- readr::read_delim(url, delim = ";") %>% 
    select(id, siglaTipo, numero, ano) %>% 
    distinct()
  
  return(propositions)
}

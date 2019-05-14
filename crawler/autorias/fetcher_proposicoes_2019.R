library(tidyverse)

filterProposicoes <- function(df) {
  codTipoList <- c(133, 143, 144, 345, 355, 635, 845)
  return(
    df %>% 
      filter(
        !codTipo %in% codTipoList &
          stringr::str_detect(dataApresentacao, '2019')
      ) %>%
      mutate(dataApresentacao = as.POSIXct(dataApresentacao)) %>% 
      filter(dataApresentacao > as.POSIXct("2019-02-01")) %>% 
      select(id,
             descricao = descricaoTipo,
             uri,
             linkInteiroTeor = urlInteiroTeor)
  )
}

exportaProposicoes <- function(df,
                               outpath = here::here("crawler/raw_data/proposicoes_2019.csv")) {
  df <-
    df %>%
    filterProposicoes() %>%
    write_csv(outpath)
  
  return(df)
}

url <- 
  "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"

df <- 
  readr::read_delim(url, delim = ";")
df <- exportaProposicoes(df)

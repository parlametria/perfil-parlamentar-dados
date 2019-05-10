library(tidyverse)

filterProposicoes <- function(df) {
  codTipoList <- c(130, 131, 136, 138, 139, 140, 143, 147, 148, 195, 255, 260, 290, 294, 304, 305, 308, 310, 318, 319, 363)
  
  return(
    df %>%
      filter(
        codTipo %in% codTipoList &
          stringr::str_detect(dataApresentacao, '2019')
      ) %>%
      select(id,
             uri = urlInteiroTeor)
  )
  
}

exportaProposicoes <- function(filepath, 
                               outpath = here::here("crawler/raw_data/proposicoes_2019.csv")) {
  df <- 
    read_delim(filepath, delim=";", quote = "\"", escape_backslash = FALSE) %>% 
    filterProposicoes() %>% 
    write_csv(outpath)
}

exportaProposicoes('~/Downloads/proposicoes-2019.csv')

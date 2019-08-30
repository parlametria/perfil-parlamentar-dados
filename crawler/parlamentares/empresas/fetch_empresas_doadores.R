paraleliza_empresas_doadores <- function(empresas_doadores) { 
  source(here::here("crawler/parlamentares/empresas/fetch_empresas.R"))
  library(tidyverse)
  
  n <- 3000
  nr <- nrow(empresas_doadores)
  dfs <- split(empresas_doadores, rep(1:ceiling(nr/n), each=n, length.out=nr))
  
  list2env(dfs, envir=.GlobalEnv)
  
  # 1 ao 5, 6 ao 10, 11 ao 13, 14 ao 15, 16 ao 18, 19 a 21, 22
  
  parte <- 1:5 %>% map(function(x) {
    return(get(as.character(x)))
  })
  
  empresas_agricolas <- parte %>% 
    map(function(x) {
      process_empresas_rurais_doadores(x)
    })
  
  res <- do.call(rbind.data.frame, empresas_agricolas)
  
  write_csv(res, here("crawler/raw_data/empresas_agricolas_doadores_parte_7.csv"))
}

une_empresas_doadores <- function() {
  library(tidyverse)
  library(here)
  
  path <- here("crawler/raw_data/")
  
  files <- list.files(path, "empresas_agricolas_doadores_*", full.names = TRUE)
  
  df <- purrr::map_df(files, ~ readr::read_csv(.x, col_types = "cccccc")) %>% 
    distinct()
  
  write_csv(df, paste0(path, 'empresas_doadores_agricolas.csv'))
}
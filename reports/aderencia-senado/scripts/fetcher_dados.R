fetch_aderencia <- function() {
  library(tidyverse)
  source(here::here("crawler/votacoes/aderencia/analyzer_aderencia.R"))
  
  aderencia <- processa_aderencia_senado()
  
  readr::write_csv(aderencia, "reports/aderencia-senado/data/aderencia.csv")
}

fetch_aderencia()
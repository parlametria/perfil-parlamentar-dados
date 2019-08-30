process_empresas_doadores <- function() {
  library(tidyverse)
  library(here)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), 
                            col_types = cols(.default = "c")) %>% 
    filter(casa == "camara") %>% 
    select(id, nome_eleitoral, partido = sg_partido, uf)
  
  empresas_doadores <- read_csv(here("crawler/raw_data/empresas_doadores_agricolas.csv"),
                                col_types = cols(.default = "c"))
  
  empresas_doadores_com_nome_deputado <- empresas_doadores %>% 
    left_join(parlamentares, by = c("id_deputado" = "id"))
  
  
  
}
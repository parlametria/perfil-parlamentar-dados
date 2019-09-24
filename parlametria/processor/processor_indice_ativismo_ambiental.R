process_indice_ativismo_ambiental <- function() {
  library(tidyverse)
  
  parlamentares <-
    read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>%
    filter(casa == "camara", em_exercicio == 1) %>%
    select(id)
  
  # Discursos analisados pela RAC
  discursos_rac <-
    read_csv(here::here(
      "parlametria/raw_data/discursos_rac/discursos_parlamentares.csv"
    ))
  
  # Aderência ao meio ambiente
  aderencia <-
    read_csv(here::here("crawler/raw_data/parlamentares_aderencia.csv")) %>%
    select(id, aderencia) %>%
    mutate(aderencia = if_else(aderencia == -1 |
                                 is.na(aderencia), 0, 1 - aderencia))
  
  indice_ativismo_ambiental <- parlamentares %>%
    inner_join(discursos_rac, by = "id") %>%
    inner_join(aderencia, by = "id") %>%
    mutate(indice_ativismo_ambiental = discurso_normalizado + aderencia / 2)
  
  return(indice_ativismo_ambiental)
}

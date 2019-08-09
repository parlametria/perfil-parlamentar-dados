#' @title Processamento de dados de Partidos e Blocos na Câmara e no Senado
#' @description Processa dados de partidos e bloco da Câmara dos Deputados e do Senado Federal
#' @return Dataframe de contendo informações sobre partidos e blocos
#' @examples
#' partidos <- processa_partidos_blocos()
processa_partidos_blocos <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/parlamentares/partidos/fetcher_partidos_camara.R"))
  source(here("crawler/parlamentares/partidos/fetcher_partidos_senado.R"))
  
  partidos_camara <- process_partidos_por_leg()
  
  partidos_senado <- fetch_partidos_senado() %>%
    filter(!str_detect(sigla, "PODEMOS"))

  partidos_senado_filtrado <- partidos_senado %>%
    filter(!(sigla %in% (partidos_camara %>% pull(sigla))))

  partidos <- partidos_camara %>%
    rbind(partidos_senado_filtrado)

  check_unique_id <- partidos %>% count(id) %>% nrow()

  if (check_unique_id != (partidos %>% nrow())) {
    stop("IDs repetidos para o dataframe de Partidos")
  }
  
  return(partidos)
}
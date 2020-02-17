#' @title Processa dados dos cargos políticos
#' @description Processa os dados dos cargos políticos e retorna no formato  a ser utilizado pelo banco de dados
#' @param mandatos_path Caminho para o arquivo de dados de cargos políticos
#' @return Dataframe com informações dos cargos políticos (mandatos)
processa_mandatos <- function(
  mandatos_path = here::here("parlametria/raw_data/cargos_politicos/historico_parlamentares_cargos_politicos.csv")) {
  library(tidyverse)
  
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  mandatos <- read_csv(mandatos_path, col_types = cols(id_parlamentar = "c"))
  
  mandatos_partidos <- mandatos %>% 
    group_by(sigla_partido_eleicao) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(sigla_partido_eleicao)) %>% 
    ungroup()
  
  mandatos_alt <- mandatos %>% 
    mutate(casa_enum = dplyr::if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa_enum, as.character(id_parlamentar)),
           id_mandato_voz = paste0(id_parlamentar_voz, ano_eleicao)) %>% 
    left_join(mandatos_partidos %>% select(id_partido, sigla_partido_eleicao), by = c("sigla_partido_eleicao")) %>% 
    select(id_mandato_voz, id_parlamentar_voz, ano_eleicao, num_turno, cargo, unidade_eleitoral,
           uf_eleitoral, situacao_candidatura, situacao_totalizacao_turno, id_partido_eleicao = id_partido, 
           votos)
  
  return(mandatos_alt)
}

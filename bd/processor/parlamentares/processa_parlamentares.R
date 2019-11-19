#' @title Processa dados dos parlamentares
#' @description Processa os dados dos parlamentares e retorna no formato correto para o banco de dados
#' @param parlamentares_data_path Caminho para o arquivo de dados dos parlamentares sem tratamento
#' @return Dataframe com informações detalhadas dos parlamentares
processa_parlamentares <- function(parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  source(here("bd/processor/perfil_politico/processa_perfil_politico.R"))
  
  parlamentares <- read_csv(parlamentares_data_path, col_types = cols(cpf = "c", data_nascimento = "c"))
  
  parlamentares_perfil_politico <- processa_perfil_politico() %>% 
    select(id_parlamentar_voz, id_perfil_politico)
  
  parlamentares_partidos <- parlamentares %>% 
    group_by(sg_partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(sg_partido)) %>% 
    ungroup()
  
  parlamentares_alt <- parlamentares %>%
    mutate(id_parlamentar_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2), 
      id)) %>% 
    left_join(parlamentares_partidos %>% select(id_partido, sg_partido), by = c("sg_partido")) %>% 
    left_join(parlamentares_perfil_politico, by = c("id_parlamentar_voz")) %>% 
    select(
      id_parlamentar_voz,
      id_parlamentar = id,
      casa,
      cpf,
      nome_civil,
      nome_eleitoral,
      genero,
      uf,
      id_partido,
      situacao,
      condicao_eleitoral,
      ultima_legislatura,
      em_exercicio,
      id_perfil_politico
    )
  
  return(parlamentares_alt)
}
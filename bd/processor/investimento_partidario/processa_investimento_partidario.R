#' @title Processa dados de investimento partidário nos parlamentares
#' @description Processa os dados de investimento partidário nos parlamentares e retorna no formato  a ser utilizado pelo banco de dados
#' @param investimento_partidario_path Caminho para o arquivo de dados de investimento partidário nos parlamentares sem tratamento
#' @return Dataframe com informações de investimento partidário nos parlamentares (deputados e senadores)
processa_investimento_partidario <- function(
  investimento_partidario_path = here::here("parlametria/raw_data/resumo/parlamentares_investimento.csv")) {
  library(tidyverse)
  
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  investimento <- read_csv(investimento_partidario_path) %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id))
    )
  
  investimento_partidos <- investimento %>% 
    select(partido = sg_partido) %>% 
    rbind(investimento %>% select(partido = partido_eleicao)) %>% 
    distinct(partido) %>% 
    group_by(partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(partido)) %>% 
    ungroup()
  
  investimento_alt <- investimento %>% 
    select(id_parlamentar_voz, partido_atual = sg_partido, partido_eleicao, total_receita_partido, total_receita_candidato, indice_investimento_partido = proporcao_campanhas_medias_receita) %>% 
    left_join(investimento_partidos %>% select(id_partido_atual = id_partido, partido), by = c("partido_atual" = "partido")) %>% 
    left_join(investimento_partidos %>% select(id_partido_eleicao = id_partido, partido), by = c("partido_eleicao" = "partido")) %>% 
    distinct(id_parlamentar_voz, .keep_all = TRUE) %>% 
    select(id_parlamentar_voz, id_partido_atual, id_partido_eleicao, total_receita_partido, total_receita_candidato,
           indice_investimento_partido)
  
  return(investimento_alt)
}

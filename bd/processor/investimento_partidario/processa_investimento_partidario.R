#' @title Processa dados de investimento realizados por Partidos durante as eleições de 2018
#' @description A partir dos dados do TSE recupera o somatório de todo o investimento realizado pelos partidos em 
#' candidatos aos cargos de deputado federal e senador.
#' @param doacoes_path caminho para o arquivo de todas as doações ocorridas nas eleições de 2018 
#' para deputado federal e senador.
#' @return Dataframe com informações de doações partidárias para cargos no congresso nacional.
processa_investimento_partidario <- function(
  doacoes_path = here::here("parlametria/raw_data/receitas/candidatos_congresso_doadores_2018.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  ## Filtra apenas doações de partidos
  doacoes_partidos <- read_csv(doacoes_path, col_types = cols(NR_CPF_CANDIDATO = "c")) %>% 
    filter(str_detect(DS_ORIGEM_RECEITA, "Recursos de partido político"))
  
  ## Agrupa por partido e UF para obter total doado
  doacoes_partidos_deputados <- doacoes_partidos %>% 
    filter(DS_CARGO == "Deputado Federal") %>% 
    group_by(SG_PARTIDO, SG_UE) %>% 
    summarise(TOTAL = sum(VR_RECEITA)) %>% 
    ungroup() %>% 
    mutate(esfera = "camara") %>% 
    select(sg_partido = SG_PARTIDO, uf = SG_UE, esfera, valor = TOTAL)
    
  doacoes_partidos_deputados_senadores <- doacoes_partidos %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador")) %>% 
    group_by(SG_PARTIDO, SG_UE) %>% 
    summarise(TOTAL = sum(VR_RECEITA)) %>% 
    ungroup() %>% 
    mutate(esfera = "senado") %>% 
    select(sg_partido = SG_PARTIDO, uf = SG_UE, esfera, valor = TOTAL)
  
  doacoes_partidos_alt <- doacoes_partidos_deputados %>% 
    rbind(doacoes_partidos_deputados_senadores) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(sg_partido)) %>% 
    ungroup() %>% 
    select(id_partido, uf, esfera, valor)
  
  return(doacoes_partidos_alt)
}

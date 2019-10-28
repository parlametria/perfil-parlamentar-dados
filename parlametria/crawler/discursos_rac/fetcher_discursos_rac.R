#' @title Baixa e retorna os dados da análise do discurso dos parlamentares feita pela RAC
#' @description Recebe uma url para a planilha e retorna os dados da análise do discurso dos 
#' parlamentares feita pela RAC
#' @param url_analise URL para planilha feita pela RAC
#' @param parlamentares_datapath Caminho para o dataframe dos parlamentares
#' @return Dataframe contendo informações sobre os discursos dos deputados
fetch_analise_discursos_rac <- function(
  url_analise = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTSsosKOoLys4UpQ4FnPWQBswj5JvFHZ282HCC1Drh21F2nPknX4ieY6NUX8n8dfQR53HCVfWezKUXy/pub?gid=1003410603&single=true&output=csv",
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {

  library(tidyverse)
  
  source(here::here("crawler/utils/utils.R"))
  
  analise_pulso <- read_csv(url_analise) %>%
    select(parlamentar = Parlamentar, discurso = Discursos) %>%
    
    mutate(parlamentar_split = strsplit(parlamentar, split = '(', fixed = TRUE)) %>%
    unnest(parlamentar_split) %>%
    
    group_by(parlamentar) %>%
    mutate(col = seq_along(parlamentar)) %>%
    spread(key = col, value = parlamentar_split) %>%
    ungroup() %>%
    
    mutate(partido_estado = stringr::str_remove(`2`, "\\)")) %>%
    select(parlamentar, discurso, nome = `1`, partido_estado) %>%
    
    mutate(partido_estado_split = strsplit(partido_estado, split = '/')) %>%
    unnest(partido_estado_split) %>%
    
    group_by(parlamentar) %>%
    mutate(col = seq_along(parlamentar)) %>%
    spread(key = col, value = partido_estado_split) %>%
    ungroup() %>%
    
    select(nome, partido = `1`, uf = `2`, parlamentar, discurso)
  
  analise_pulso <- analise_pulso %>% 
    mutate(nome = gsub("[ ]*[^ ]*$", "", padroniza_nome(nome)))
    
  
  parlamentares <- read_csv(parlamentares_datapath) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(nome_eleitoral, id, cpf) %>% 
    mutate(nome_eleitoral = padroniza_nome(nome_eleitoral))
  
  res <- analise_pulso %>% 
    right_join(parlamentares, by = c("nome" = "nome_eleitoral")) %>% 
    select(id, discurso) %>% 
    mutate(discurso = if_else(is.na(discurso), 0, as.numeric(discurso))) %>% 
    mutate(discurso_normalizado = if_else(discurso / 3 > 1, 1, discurso / 3)) %>% 
    select(-discurso)
  
  return(res)
}
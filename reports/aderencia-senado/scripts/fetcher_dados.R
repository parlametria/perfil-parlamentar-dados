library(tidyverse)

fetch_proposicoes <- function(){
  source(here::here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
  
  proposicoes <- fetch_proposicoes_plenario_selecionadas_senado() %>%
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>% 
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    select(-n_prop) %>% 
    mutate(id_proposicao = as.numeric(id_proposicao))
  
  readr::write_csv(proposicoes, here::here("reports/aderencia-senado/data/proposicoes.csv"))
  
  return(proposicoes)
}

fetch_votacoes <- function() {
  source(here::here("crawler/votacoes/fetcher_votacoes_senado.R"))
  
  votacoes <- fetcher_votacoes_por_intervalo_senado()
  readr::write_csv(votacoes, here::here("reports/aderencia-senado/data/votacoes.csv"))
  
  return(votacoes)
}

fetch_senadores <- function() {
  source(here::here("crawler/parlamentares/analyzer_parlamentar.R"))
  
  senadores <- processa_dados_senadores()
  readr::write_csv(senadores, here::here("reports/aderencia-senado/data/senadores.csv"))
  
  return(senadores)
}

fetch_votos <- function() {
  source(here::here("crawler/votacoes/votos/analyzer_votos.R"))
  
  votos <- process_votos_por_votacoes_senado(here::here("reports/aderencia-senado/data/votacoes.csv"))
  readr::write_csv(votos, here::here("reports/aderencia-senado/data/votos.csv"))
  
  return(votos)
  
}

fetch_orientacoes <- function() {
  source(here::here("crawler/votacoes/orientacoes/analyzer_orientacoes.R"))
  
  orientacoes <- process_orientacao_senado(here::here("reports/aderencia-senado/data/votos.csv"))
  readr::write_csv(votos, here::here("reports/aderencia-senado/data/orientacoes.csv"))
  
  return(orientacoes)
}

proposicoes <- fetch_proposicoes_plenario_selecionadas_senado()
votacoes <- fetch_votacoes()
senadores <- fetch_senadores()
votos <- fetch_votos()
orientacoes <- fetch_orientacoes()

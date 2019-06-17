#' @title Lista com votos e orientações para as proposições votadas em plenário em 2019
#' @description Retorna os votos e as orientações dos partidos para as votações em 2019 
#' @return Lista contendo dois dataframes (votos e orientações)
#' @examples
#' votos_orientacao <- processa_dados_votacoes()
processa_dados_votacoes <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/utils_votacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara") %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  proposicoes_votadas <- fetch_votacoes_ano(2019) %>% 
    rbind(fetch_votacoes_ano(2020)) %>% 
    rbind(fetch_votacoes_ano(2021)) %>% 
    rbind(fetch_votacoes_ano(2022)) 

  votos <- read_csv(here("crawler/raw_data/votos.csv"))
  
  orientacao <- read_csv(here("crawler/raw_data/orientacoes.csv"))
  
  return(list(deputados, proposicoes_votadas, votos, orientacao))
}

#' @title Calcula os dados de aderência do deputado a um partido ou ao governo
#' @description Retorna dados de aderência dos deputados por votação e de forma sumarizada
#' @param deputados_votos Dataframe de deputados com os votos do deputado e os do partido (pode ser GOVERNO)
#' @param filtrar TRUE se deseja filtrar fora os partidos com menos de 5 membros e os deputados com menos de 10 votações. 
#' FALSE se quiser capturar todos os deputados
#' @return Lista com dataframes com informações dos deputados e seus dados de aderência sumarizados e por votação
#' @examples
#' dados_aderencia <- processa_calculo_aderencia(votos, filtrar = FALSE)
processa_calculo_aderencia <- function(deputados_votos, deputados, filtrar = TRUE) {
  library(tidyverse)
  
  source(here("crawler/votacoes/votos_orientacao/calcula_aderencia.R"))
  
  if (filtrar) {
    minimo_votacoes_por_deputado <- 10
    minimo_membros_partido <- 5
  } else {
    minimo_votacoes_por_deputado <- 0
    minimo_membros_partido <- 0
  }
  
  deputados_votos_match <- deputados_votos %>%
    rowwise() %>% 
    mutate(match = compara_voto_com_orientacao(voto_deputado, voto_partido)) %>% 
    ungroup()
  
  deputados_summary_long <- deputados_votos_match %>% 
    group_by(id_deputado, partido, match) %>% 
    summarise(n = n()) %>% 
    mutate(match = case_when(
      match == -2 ~ "faltou",
      match == -1 ~ "nao_seguiu",
      match == 0 ~ "nao_calculado",
      match == 1 ~ "seguiu",
      match == 2 ~ "partido_liberou"
    )) %>% 
    ungroup() %>% 
    left_join(deputados %>% select(id, nome_eleitoral, uf), by = c("id_deputado" = "id")) %>% 
    mutate(nome = if_else(partido == "GOVERNO", nome_eleitoral, 
             paste0(str_to_title(nome_eleitoral), " - ", partido, "/", uf))) %>% 
    select(id_deputado, nome, partido, match, n) %>% 
    filter(!is.na(id_deputado))
  
  deputados_summary_freq_wide <- deputados_summary_long %>% 
    spread(key = match, value = n) %>% 
    replace(is.na(.), 0) %>% 
    mutate(total_votacoes = seguiu + nao_seguiu) %>% 
    filter(total_votacoes >= minimo_votacoes_por_deputado) %>% 
    mutate(freq = (seguiu / (seguiu + nao_seguiu)) * 100) %>% 
    filter(!is.na(freq)) %>% 
    arrange(freq) %>% 
    select(id_deputado, nome, partido, faltou, partido_liberou, nao_seguiu, seguiu, total_votacoes, freq)
  
  partidos_count <- deputados_summary_freq_wide %>% 
    group_by(partido) %>% 
    summarise(n = n()) %>% 
    filter(n >= minimo_membros_partido) %>% 
    pull(partido)
  
  deputados_summary_freq_wide <- deputados_summary_freq_wide %>% 
    filter(partido %in% partidos_count)
  
  return(list(deputados_votos_match, deputados_summary_freq_wide))
}

#' @title Processa os dados de aderência do deputado ao partido
#' @description Retorna dados de aderência dos deputados por votação e de forma sumarizada
#' @param votos Dataframe de votos
#' @param orientacao Dataframe de orientações
#' @param deputados Dataframe de deputados
#' @param filtrar TRUE se deseja filtrar fora os partidos com menos de 5 membros e os deputados com menos de 10 votações. 
#' FALSE se quiser capturar todos os deputados
#' @return Lista com dataframes com informações dos deputados e seus dados de aderência sumarizados e por votação
#' @examples
#' dados_aderencia <- processa_dados_deputado_aderencia(votos, orientacao, deputados)
processa_dados_deputado_aderencia <- function(votos, orientacao, deputados, filtrar = TRUE) {
  library(tidyverse)
  
  deputados_votos <- votos %>% 
    left_join(orientacao, 
              by = c("id_proposicao", "id_votacao", "partido")) %>% 
    rename(voto_deputado = voto.x,
           voto_partido = voto.y) %>% 
    mutate(id_deputado = as.character(id_parlamentar),
           partido_parlamentar = partido)

  return(processa_calculo_aderencia(deputados_votos, deputados, filtrar))
}

#' @title Processa os dados de aderência do deputado ao Governo
#' @description Retorna dados de aderência dos deputados por votação e de forma sumarizada
#' @param votos Dataframe de votos
#' @param orientacao Dataframe de orientações
#' @param deputados Dataframe de deputados
#' @param filtrar TRUE se deseja filtrar fora os partidos com menos de 5 membros e os deputados com menos de 10 votações. 
#' FALSE se quiser capturar todos os deputados
#' @return Lista com dataframes com informações dos deputados e seus dados de aderência sumarizados e por votação
#' @examples
#' dados_aderencia <- processa_dados_deputado_aderencia_governo(votos, orientacao, deputados, filtrar = FALSE)
processa_dados_deputado_aderencia_governo <- function(votos, orientacao, deputados, filtrar = TRUE) {
  library(tidyverse)
  
  deputados_votos <- votos %>% 
    left_join(orientacao %>% filter(partido == "GOVERNO"),
              by = c("id_proposicao", "id_votacao")) %>% 
    rename(voto_deputado = voto.x,
           voto_partido = voto.y,
           partido_parlamentar = partido.x,
           partido = partido.y,
           ano = ano.y
           ) %>% 
    mutate(id_deputado = as.character(id_parlamentar),
           partido = "GOVERNO") %>% 
    filter(!is.na(id_deputado))
    
  return(processa_calculo_aderencia(deputados_votos, deputados, filtrar))
}

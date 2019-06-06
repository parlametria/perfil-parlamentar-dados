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
  
  proposicoes_votadas <- fetch_votacoes_ano(2019)

  votos <- read_csv(here("crawler/raw_data/votos_2019.csv"))
  
  orientacao <- read_csv(here("crawler/raw_data/orientacoes_2019.csv"))
  
  return(list(deputados, proposicoes_votadas, votos, orientacao))
}

#' @title Processa os dados de aderência do deputado ao partido
#' @description Retorna dados de aderência dos deputados por votação e de forma sumarizada
#' @param ano Ano de ocorrência das votações
#' @param ano Ano de ocorrência das votações
#' @param ano Ano de ocorrência das votações
#' @return Dataframe contendo id da proposição, nome e data da votação
#' @examples
#' dados_aderencia <- processa_dados_deputado_aderencia(votos, orientacao, deputados)
processa_dados_deputado_aderencia <- function(votos, orientacao, deputados) {
  library(tidyverse)
  
  source(here("crawler/votacoes/votos_orientacao/calcula_aderencia.R"))
  
  deputados_votos <- votos %>% 
    left_join(orientacao, 
              by = c("id_proposicao", "id_votacao", "partido")) %>% 
    rename(voto_deputado = voto.x,
           voto_partido = voto.y) %>% 
    mutate(id_deputado = as.character(id_deputado))
  
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
    left_join(deputados %>% select(id, nome_eleitoral, uf), by = c("id_deputado" = "id")) %>% 
    mutate(nome = paste0(str_to_title(nome_eleitoral), " - ", partido, "/", uf)) %>% 
    ungroup() %>% 
    select(id_deputado, nome, partido, match, n)
  
  minimo_votacoes_por_deputado <- 10
  
  deputados_summary_freq_wide <- deputados_summary_long %>% 
    spread(key = match, value = n) %>% 
    replace(is.na(.), 0) %>% 
    mutate(total_votacoes = seguiu + nao_seguiu) %>% 
    filter(total_votacoes >= 10) %>% 
    mutate(freq = (seguiu / (seguiu + nao_seguiu)) * 100) %>% 
    filter(!is.na(freq)) %>% 
    arrange(freq) %>% 
    select(id_deputado, nome, partido, faltou, partido_liberou, nao_seguiu, seguiu, total_votacoes, freq)
  
  minimo_membros_partido <- 5
  
  partidos_count <- deputados_summary_freq_wide %>% 
    group_by(partido) %>% 
    summarise(n = n()) %>% 
    filter(n >= 5) %>% 
    pull(partido)
  
  deputados_summary_freq_wide <- deputados_summary_freq_wide %>% 
    filter(partido %in% partidos_count)
  
  return(list(deputados_votos_match, deputados_summary_freq_wide))
}

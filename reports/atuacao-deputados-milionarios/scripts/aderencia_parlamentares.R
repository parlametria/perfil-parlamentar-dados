#' @title Calcula aderência ao Governo em todas as votações de parlamentares que recebram altas doações em 2018.
#' @description Para todas as votações nominais em plenário realizadas em 2019 na Câmara, calcula a aderência
#' a orientação do Governo para uma lista de parlamentares passadas como parâmetro.
#' @param url_planilha_deputados_selecionados Lista de parlamentares para cálculo da aderência
#' @param filtrar_temas_governo TRUE se devem ser consideradas apenas votações classificadas como Agenda Nacional ou
#' que são MPV's. FALSE é o default e considera todas as votações
#' @return Dataframe com informações da aderência de parlamentares as orientações do governo.
#' @examples
#' calcula_aderencia_parlamentares_milionarios()
calcula_aderencia_parlamentares_milionarios <- function(
  url_planilha_deputados_selecionados = "https://docs.google.com/spreadsheets/d/e/2PACX-1vShw-2Or9QH4WzRagrBxvWC9eqBRCiYaKkgV7YUlExxb8spHNW6k-VCeDmnv1peK7caIVdyBuW6V_kG/pub?gid=0&single=true&output=csv",
  filtrar_temas_governo = FALSE
) {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/aderencia/processa_dados_aderencia.R"))
  
  parlamentares <- read_csv(here("reports/atuacao-deputados-milionarios/data/parlamentares.csv"),
                            col_types = cols(id = "c"))
  
  ## Lista de parlamentares selecionados (altas doações em 2018)
  parlamentares_ids <- read_csv(url_planilha_deputados_selecionados, col_types = cols(id = "c")) %>% 
    distinct(id) %>% 
    pull(id)
  
  votos <- read_csv(here("reports/atuacao-deputados-milionarios/data/votos.csv"),
                    col_types = cols(.default = "c", id_deputado = "c", voto = "i")) %>% 
    rename(id_parlamentar = id_deputado) %>% 
    mutate(ano = 2019, casa = "camara") %>% 
    select(ano, id_proposicao, id_votacao, id_parlamentar, voto, partido, casa)
  
  orientacoes <- read_csv(here("reports/atuacao-deputados-milionarios/data/orientacoes.csv"),
                          col_types = cols(.default = "c", voto = "i")) %>% 
    mutate(ano = 2019, casa = "camara") %>% 
    select(ano, id_proposicao, id_votacao, partido, voto, casa)
  
  if(filtrar_temas_governo) {
    votos_orientacoes <- filtra_votos_orientacoes(votos, orientacoes)
    
    votos <- votos_orientacoes[[1]]
    orientacoes <- votos_orientacoes[[2]]
  }
  
  dados_aderencia_governo <- processa_dados_deputado_aderencia_governo(votos, orientacoes, parlamentares,
                                                                       casa = "camara",
                                                                       filtrar = FALSE)
  
  aderencia_governo_votacao <- dados_aderencia_governo[[1]]
  aderencia_governo_summary <- dados_aderencia_governo[[2]]
  
  parlamentares_lista <- parlamentares %>% 
    mutate(selecionado = id %in% parlamentares_ids) %>% 
    filter(em_exercicio == 1, casa == "camara") %>% 
    
    left_join(aderencia_governo_summary, by = c("id")) %>% 
    select(id, casa, nome_eleitoral, uf, sg_partido, faltou, liberado = partido_liberou, 
           nao_seguiu, seguiu, total_votacoes, aderencia = freq, selecionado)

  return(parlamentares_lista)  
}

#' @title Filtra votos e orientações de proposições do tema de Agenda Nacional ou MPV's
#' @description A partir da lista de proposições do tema de Agenda Nacional ou MPV's filtra 
#' votos e orientações.
#' @param votos Votos para serem filtrados
#' @param orientacoes Orientações para serem filtradas
#' @return Lista de dataframes com informações de votos e orientação
#' @examples
#' filtra_votos_orientacoes_agenda_nacional(votos, orientacoes)
filtra_votos_orientacoes <- function(votos, orientacoes) {
  library(tidyverse)
  library(here)
  source(here("crawler/proposicoes/process_proposicao_tema.R"))
  source(here("crawler/proposicoes/fetch_proposicoes_voz_ativa.R"))
  source(here("crawler/proposicoes/utils_proposicoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
  
  proposicoes_plenario <- fetch_proposicoes_votadas_por_ano_camara(2019) %>% 
    distinct(id, nome_proposicao) %>% 
    select(id_proposicao = id, nome_proposicao)
  
  proposicoes_temas <- process_proposicoes_plenario_selecionadas_temas(.URL_PROPOSICOES_PLENARIO_CAMARA)
  
  proposicoes_agenda_nacional_mpv <- proposicoes_plenario %>% 
    left_join(proposicoes_temas, by = c("id_proposicao")) %>% 
    filter(id_tema == 3 | str_detect(nome_proposicao, "MPV")) ## 3 é o tema de agenda nacional
  
  ids_proposicoes_agenda_nacional_mpv <- proposicoes_agenda_nacional_mpv %>% 
    distinct(id_proposicao) %>% 
    pull(id_proposicao)
  
  votos_filtered <- votos %>% 
    filter(id_proposicao %in% ids_proposicoes_agenda_nacional_mpv)
  
  orientacoes_filtered <- orientacoes %>% 
    filter(id_proposicao %in% ids_proposicoes_agenda_nacional_mpv)
  
  return(list(votos_filtered, orientacoes_filtered))
}

#' @title Calcula aderência para lista de parlamentares 
#' (com todos os temas e para temas do Governo: Agenda Nacional e MPV)
#' @description Calcula aderência para lista de parlamentares 
#' (com todos os temas e para temas do Governo: Agenda Nacional e MPV)
#' @return Dataframe com informações da Aderência de parlamentares
#' @examples
#' processa_aderencia_parlamentares_lista()
processa_aderencia_parlamentares_lista <- function() {
  library(tidyverse)
  library(here)
  
  todas_votacoes <- calcula_aderencia_parlamentares_milionarios(filtrar_temas_governo = FALSE)
  
  votacoes_temas_governo <- calcula_aderencia_parlamentares_milionarios(filtrar_temas_governo = TRUE) %>% 
    select(id, casa, aderencia_temas_governo = aderencia)
  
  aderencia_alt <- todas_votacoes %>% 
    left_join(votacoes_temas_governo, by = c("id", "casa"))
  
  return(aderencia_alt)
}

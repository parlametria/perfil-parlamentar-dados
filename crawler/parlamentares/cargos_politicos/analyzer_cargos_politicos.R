#' @title Processa todos os cargos de eleição desde 1998
#' @description Processa os cargos políticos e seus ocupantes desde 1998.
#' @return Dataframe contendo os cargos políticos de 1998 a 2018.
#' @example analyzer_cargos_politicos()
analyzer_cargos_politicos <- function() {
  library(tidyverse)
  source(here::here("crawler/parlamentares/cargos_politicos/fetch_cargos_politicos.R"))
  
  cargos_parlamentares <- fetch_all_cargos_politicos()
    
  cargos_parlamentares <- cargos_parlamentares %>% 
    select(id_parlamentar = id, 
           cpf, 
           nome_eleitoral, 
           partido = sg_partido, 
           uf, 
           ano_eleicao = ANO_ELEICAO,
           num_turno = NUM_TURNO,
           cargo = DESCRICAO_CARGO, 
           uf_eleitoral = SIGLA_UE,
           situacao_candidatura = DES_SITUACAO_CANDIDATURA,
           situacao_totalizacao_turno = DESC_SIT_TOT_TURNO,
           numero_urna = NUMERO_CANDIDATO,
           sigla_partido_eleicao = SIGLA_PARTIDO,
           composicao_coligacao = COMPOSICAO_COLIGACAO,
           votos = QTDE_VOTOS
    ) %>% 
    mutate(composicao_coligacao = if_else(str_detect(composicao_coligacao, '#NE#|#NULO#'),
                                          as.character(NA),
                                          composicao_coligacao))
  
  cargos_parlamentares_filtered <- 
    filter_suplentes_com_exercicio(cargos_parlamentares)
  
  return(cargos_parlamentares_filtered)
}

#' @title Filtra os parlamentares suplentes que estiveram em exercício
#' @description Recebe um dataframe de cargos parlamentares e um caminho para os mandatos e 
#' filtra de cargos parlamentaresos parlamentares suplentes que tiveram exercício em algum momento.
#' @param cargos_parlamentares Dataframe contendo pelo menos as colunas id_parlamentar e ano_eleicao
#' @param mandatos_datapath Caminho para o dataframe de mandatos contendo pelo menos as colunas
#' id_parlamentar e ano_eleicao
#' @return Dataframe contendo o histórico de cargos públicos contendo os suplentes que assumiram algum
#' momento.
filter_suplentes_com_exercicio <- function(
  cargos_parlamentares = readr::read_csv(here::here("crawler/raw_data/historico_parlamentares_cargos_politicos.csv")),
  mandatos_datapath = here::here("crawler/raw_data/mandatos.csv")) {
  
  library(tidyverse)
  
  mandatos <- read_csv(mandatos_datapath)
  
  suplentes_que_tiveram_exercicio <- cargos_parlamentares %>%
    filter(situacao_totalizacao_turno == "SUPLENTE") %>%
    mutate(
      id_legislatura =
        case_when(
          ano_eleicao == 2018 ~ 56,
          ano_eleicao == 2014 ~ 55,
          ano_eleicao == 2010 ~ 54,
          ano_eleicao == 2006 ~ 53,
          ano_eleicao == 2002 ~ 52,
          ano_eleicao == 1998 ~ 51,
          TRUE ~ as.numeric(NA)
        )
    ) %>%
    inner_join(mandatos %>%
                 select(id_parlamentar, id_legislatura),  
               by = c("id_parlamentar", "id_legislatura")) %>% 
    select(-id_legislatura)
  
  cargos_parlamentares <- cargos_parlamentares %>% 
    filter(situacao_totalizacao_turno != "SUPLENTE") %>% 
    rbind(suplentes_que_tiveram_exercicio)
  
  return(cargos_parlamentares)
}
#' @title Processa índice de proporção de receita oriunda de partidos para parlamentares.
#' @description Calcula o índice de investimento do partido no Parlamentar (deputado ou senador) em termos proporcionais de campanha 
#' média (eleições de 2018)
#' @param receita_partido_datapath Caminho para dados de receitas recebidas dos parlamentares através dos seus partidos.
#' @return Dataframe contendo informações do nível de investimento do partido no parlamentar durante as eleições de 2018.
#' @examples
#' receita_indice_investimento_partidario <- process_receita_partido()
process_receita_partido <- function(receita_partido_datapath = here::here("parlametria/raw_data/receitas/receitas_tse_2018.csv")) {
  library(tidyverse)
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  receita <- read_csv(receita_partido_datapath) %>% 
    group_by(uf, cargo) %>% 
    mutate(media_uf = mean(total_receita)) %>% 
    ungroup() %>% 
    
    mutate(proporcao_receita_uf = total_receita / media_uf) %>%
    mutate(partido = padroniza_sigla(partido)) %>% 
    
    group_by(partido) %>% 
    mutate(campanhas_total_partido = sum(proporcao_receita_uf)) %>% 
    ungroup() %>% 
    mutate(proporcao_receita = proporcao_receita_uf / campanhas_total_partido)
  
  return(receita)
}

#' @title Processa total recebido pelos candidatos a deputado federal e senador durante as eleições de 2018.
#' @description Agrupa receitas declaradas pelos candidatos a deputado federal e a senador durante as eleições de 2018 para
#' obter o total recebido pelos candidatos.
#' @param receita_candidato_datapath Caminho para dados de receitas recebidas dos candidatos.
#' @return Dataframe contendo informações do total recebido pelo candidato em doações em 2018
#' @examples
#' candidato_total_recebido <- process_receita_candidato()
process_receita_candidato <- function(receita_candidato_datapath = here::here("parlametria/raw_data/receitas/candidatos_congresso_doadores_2018.csv")) {
  library(tidyverse)
  
  
  doacoes_candidatos_2018 <- read_csv(receita_candidato_datapath,
                                      col_types = cols(NR_CPF_CANDIDATO = "c"))
  
  doacoes_por_candidato <- doacoes_candidatos_2018 %>% 
    group_by(NR_CPF_CANDIDATO) %>% 
    summarise(total_receita_candidato = sum(VR_RECEITA)) %>% 
    rename(cpf = NR_CPF_CANDIDATO)
  
  return(doacoes_por_candidato)
}

#' @title Processa dados de Investimento do Partido para parlamentares
#' @description Agrupa dados relacionados a receita de parlamentares (deputados e senadores) durante as eleições de 2018.
#' @param filtrar_em_exercicio Boolean com indicação se o filtro de parlamentares em exercício deve ser aplicado ou não.
#' @param casa_parlamentar String com casa do parlamentar. Poder ser 'camara' ou 'senado'
#' @return Dataframe contendo informações do nível de investimento do partido no parlamentar durante as eleições de 2018.
#' Existe a sigla do partido (partido_eleicao) no qual o parlamentar concorreu ao cargo durante as eleições de 2018.
#' @examples
#' investimento_partidario <- process_investimento_partidario()
process_investimento_partidario <- function(filtrar_em_exercicio = TRUE, casa_parlamentar = NULL) {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  source(here("crawler/votacoes/utils_votacoes.R"))

  ## função process_cpf_parlamentares_senado
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  receita <- process_receita_partido() %>% 
    select(cpf, partido_eleicao = partido, total_receita_partido = total_receita, 
           proporcao_campanhas_medias_receita = proporcao_receita)
  
  doacoes_por_candidato <- process_receita_candidato()
  
  parlamentares_raw <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  ## Adiciona cpf dos senadores caso necessário (casa não é apenas câmara)
  if (is.null(casa_parlamentar) || casa_parlamentar == "senado") {
    senadores_ids <- process_cpf_parlamentares_senado() %>% 
      select(id_senador = id, cpf_senador = cpf)
    
    parlamentares_raw <- parlamentares_raw %>% 
      left_join(senadores_ids, by = c("id" = "id_senador")) %>% 
      mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
      select(-cpf_senador) %>% 
      distinct()
  }
  
  if (!is.null(casa_parlamentar)) {
    parlamentares_raw <- parlamentares_raw %>% 
      filter(casa == casa_parlamentar)
  }
  
  if (filtrar_em_exercicio) {
    parlamentares_raw <- parlamentares_raw %>% 
      filter(em_exercicio == 1)
  }
  
  parlamentares_receita <- parlamentares_raw %>% 
    left_join(receita, 
              by = c("cpf")) %>% 
    left_join(doacoes_por_candidato, 
              by = c("cpf"))
  
  return(parlamentares_receita)
}

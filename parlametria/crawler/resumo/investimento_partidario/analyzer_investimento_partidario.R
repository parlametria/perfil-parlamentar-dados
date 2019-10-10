#' @title Processa dados de Investimento do Partido para parlamentares
#' @description Calcula o investimento do partido no Parlamentar (deputado ou senador) em termos proporcionais de campanha 
#' média (eleições de 2018)
#' @param filtrar_em_exercicio Boolean com indicação se o filtro de parlamentares em exercício deve ser aplicado ou não.
#' @param casa_parlamentar String com casa do parlamentar. Poder ser 'camara' ou 'senado'
#' @return Dataframe contendo informações do nível de investimento do partido no parlamentar durante as eleições de 2018.
#' @examples
#' investimento_partidario <- process_investimento_partidario()
process_investimento_partidario <- function(filtrar_em_exercicio = TRUE, casa_parlamentar = NULL) {
  library(tidyverse)
  library(here)
  options(scipen = 999)
  
  source(here("crawler/votacoes/utils_votacoes.R"))

  ## função process_cpf_parlamentares_senado
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))
  
  receita <- read_csv(here("parlametria/raw_data/receitas/receitas_tse_2018.csv")) %>% 
    group_by(uf, cargo) %>% 
    mutate(media_uf = mean(total_receita)) %>% 
    ungroup() %>% 
    
    mutate(proporcao_receita_uf = total_receita / media_uf) %>%
    mutate(partido = padroniza_sigla(partido)) %>% 
    mutate(partido = if_else(str_detect(partido, "PATRI"), "PATRIOTA", partido)) %>% 
    mutate(partido = if_else(str_detect(partido, "PC DO B"), "PCdoB", partido)) %>% 
    
    group_by(partido) %>% 
    mutate(campanhas_total_partido = sum(proporcao_receita_uf)) %>% 
    ungroup() %>% 
    mutate(proporcao_receita = proporcao_receita_uf / campanhas_total_partido)
  
  parlamentares_raw <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  ## Adiciona cpf dos senadores caso necessário (casa não é apenas câmara)
  if (is.null(casa_parlamentar) || casa_parlamentar == "senado") {
    senadores_ids <- process_cpf_parlamentares_senado() %>% 
      select(id_senador = id, cpf_senador = cpf)
    
    parlamentares_raw <- parlamentares_raw %>% 
      left_join(senadores_ids, by = c("id" = "id_senador")) %>% 
      mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
      select(-cpf_senador)
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
    left_join(receita %>% 
                select(cpf, partido, total_receita, proporcao_campanhas_medias_receita = proporcao_receita), 
              by = c("cpf" = "cpf", "sg_partido" = "partido"))
  
  return(parlamentares_receita)
}

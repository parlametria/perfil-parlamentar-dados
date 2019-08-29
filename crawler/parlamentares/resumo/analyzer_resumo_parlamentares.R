#' @title Processa dados de Investimento do Partido para deputados.
#' @description Calcula o investimento do partido no Deputado em termos proporcionais de campanha 
#' média (eleições de 2018)
#' @return Dataframe contendo informações do nível de investimento do partido no deputado durante as eleições de 2018.
#' @examples
#' process_resumo_deputados_investimento()
process_resumo_deputados_investimento <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/utils_votacoes.R"))

  receita <- read_csv(here("crawler/raw_data/receitas_tse_2018.csv")) %>% 
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
  
  deputados_raw <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  deputados_receita <- deputados_raw %>% 
    left_join(receita %>% 
                select(cpf, partido, total_receita, proporcao_campanhas_medias_receita = proporcao_receita), 
              by = c("cpf" = "cpf", "sg_partido" = "partido"))
  
  return(deputados_receita)
}

#' @title Processa dados de Aderência em votações de Meio Ambiente
#' @description Adiciona dados de Aderência em Votações do Tema de Meio Ambiente
#' @return Dataframe contendo informações do deputado como aderência.
#' @examples
#' process_resumo_deputados_aderencia()
process_resumo_deputados_aderencia <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  deputados_raw <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  aderencia <- read_csv(here("bd/data/aderencia.csv"), col_types = cols(id_parlamentar_voz = "c")) %>% 
    filter(id_tema == 0, id_partido == 0) %>%
    mutate(id_parlamentar = substring(id_parlamentar_voz, 2)) %>% 
    select(id_parlamentar, faltou, partido_liberou, nao_seguiu, seguiu, aderencia)
  
  deputados <- deputados_raw %>% 
    left_join(aderencia, by = c("id" = "id_parlamentar")) %>% 
    arrange(desc(aderencia))
  
  return(deputados)
}

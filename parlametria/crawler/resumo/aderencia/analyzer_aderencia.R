#' @title Processa dados de Aderência em votações de Meio Ambiente
#' @description Adiciona dados de Aderência em Votações do Tema de Meio Ambiente
#' @param filtrar_em_exercicio Boolean com indicação se o filtro de parlamentares em exercício deve ser aplicado ou não.
#' @param casa_parlamentar String com casa do parlamentar. Poder ser 'camara' ou 'senado'
#' @return Dataframe contendo informações do parlamentar como aderência.
#' @examples
#' aderencia_meio_ambiente <- process_aderencia_meio_ambiente()
process_aderencia_meio_ambiente <- function(filtrar_em_exercicio = TRUE, casa_parlamentar = NULL) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  parlamentares_raw <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido))
  
  if (!is.null(casa_parlamentar)) {
    parlamentares_raw <- parlamentares_raw %>% 
      filter(casa == casa_parlamentar)
  }
  
  if (filtrar_em_exercicio) {
    parlamentares_raw <- parlamentares_raw %>% 
      filter(em_exercicio == 1)
  }
  
  id_meio_ambiente <- 0
  id_governo <- 0
  
  aderencia <- read_csv(here("bd/data/aderencia.csv"), col_types = cols(id_parlamentar_voz = "c")) %>% 
    filter(id_tema == id_meio_ambiente, id_partido == id_governo) %>%
    mutate(id_parlamentar = substring(id_parlamentar_voz, 2)) %>% 
    mutate(casa = if_else(substring(id_parlamentar_voz, 1, 1) == "1", "camara", "senado")) %>% 
    select(id_parlamentar, casa, faltou, partido_liberou, nao_seguiu, seguiu, aderencia)
  
  parlamentares <- parlamentares_raw %>% 
    left_join(aderencia, by = c("id" = "id_parlamentar", "casa" = "casa")) %>% 
    arrange(desc(aderencia))
  
  return(parlamentares)
}
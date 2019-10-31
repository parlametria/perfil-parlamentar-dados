#' @title Processa dados de cargos em comissões e de presidência em partidos e blocos partidários
#' @description Agrupa dados de cargos em comissões e partidos dos parlamentares (deputados e senadores)
#' @param filtrar_em_exercicio Boolean com indicação se o filtro de parlamentares em exercício deve ser aplicado ou não.
#' @param casa_parlamentar String com casa do parlamentar. Poder ser 'camara' ou 'senado'
#' @return Dataframe contendo informações de cargos e lideranças
#' @examples
#' cargos_parlamentares <- process_cargos_resumo_parlamentares()
process_cargos_resumo_parlamentares <- function(filtrar_em_exercicio = TRUE, casa_parlamentar = NULL) {
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
  
  comissoes <- read_csv(here("crawler/raw_data/comissoes.csv")) %>% 
    select(-casa)
  
  cargos_comissoes <- read_csv(here("crawler/raw_data/composicao_comissoes.csv"), 
                               col_types = cols(id_parlamentar = "c"))
  
  cargos_comissoes <- cargos_comissoes %>% 
    left_join(comissoes, by = c("comissao_id" = "id")) %>% 
    select(id_parlamentar, casa, cargo, sigla) %>% 
    
    group_by(id_parlamentar, casa, cargo) %>% 
    summarise(comissoes = paste0(sigla, collapse = ";")) %>% 
    
    spread(cargo, comissoes)
  
  liderancas <- read_csv(here("crawler/raw_data/liderancas.csv"), col_types = cols(id = "c")) %>% 
    select(id_parlamentar = id, casa, cargo, bloco_partido) %>% 
    
    group_by(id_parlamentar, casa, cargo) %>% 
    summarise(liderancas = paste0(bloco_partido, collapse = ";")) %>% 
    
    spread(cargo, liderancas)
  
  parlamentares <- parlamentares_raw %>% 
    left_join(cargos_comissoes, by = c("id" = "id_parlamentar", "casa" = "casa")) %>% 
    left_join(liderancas, by = c("id" = "id_parlamentar", "casa" = "casa")) %>% 
    select(id, casa, cpf, nome_eleitoral, uf, sg_partido, Presidente, `Primeiro Vice-presidente`, 
           `Segundo Vice-presidente`, `Terceiro Vice-presidente`, Titular, Suplente, `Líder`, 
           `Vice-líder`, `Representante`) %>% 
    arrange(`Presidente`)
  
  return(parlamentares)
}

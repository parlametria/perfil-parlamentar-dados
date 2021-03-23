library(tidyverse)
library(here)
source(here::here("parlametria/processor/processor_influencia_parlamentar.R"))
source(here::here("parlametria/processor/peso_politico/process_cargos_comissoes.R"))

#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
process_gera_planilha_peso_politico <- function() {
  
  parlamentares_id <- read_csv(here("crawler/raw_data/parlamentares.csv"), 
                               col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1) %>% 
    select(id, casa, nome_eleitoral, uf, sg_partido)
  
  parlamentares_processed <- process_indice_influencia_parlamentar()
  
  n_max_comissoes <- process_max_comissoes()
  
  comissoes <- .process_cargos_comissao_detalhado(n_max_comissoes)
  
  liderancas <- .process_cargos_lideranca_detalhado()
  
  cargos_mesa_detalhado <- .process_cargos_mesa_detalhado()
  
  parlamentares_planilha <- parlamentares_id %>% 
    left_join(parlamentares_processed, by = c("id", "casa")) %>% 
    left_join(comissoes, by = c("id", "casa")) %>% 
    left_join(liderancas, by = c("id", "casa")) %>% 
    left_join(cargos_mesa_detalhado, by = c("id", "casa")) %>% 
    select(id, casa, nome_eleitoral, uf, sg_partido, investimento_partidario, numero_de_mandatos, 
           `Líder`, `Vice-líder`, Representante, indice_liderancas, 
           presidente_mesa = Presidente.y, secretario_mesa = `Secretário`, suplente_secretario_mesa = `Suplente de Secretário`,
           vice_presidente_mesa = `Vice-Presidente`, indice_cargo_mesa,
           presidente_comissao = Presidente.x, primeiro_vice_presidente_comissao = `Primeiro Vice-presidente`,
           segundo_vice_presidente_comissao = `Segundo Vice-presidente`, 
           terceiro_vice_presidente_comissao = `Terceiro Vice-presidente`, Titular, max_comissoes_casa, indice_comissoes, 
           peso_politico = indice_influencia_parlamentar) %>% 
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(dplyr::everything())) %>% 
    rowwise() %>% 
    mutate(max_comissoes_casa = (n_max_comissoes %>% filter(casa_parlamentar == casa) %>% pull(max))) %>% 
    ungroup()
  
  return(parlamentares_planilha)
}

#' @description Recupera informações detalhadas dos cargos em comissões para parlamentares
#' @return Dataframe com cargos em comissões ocupados por parlamentares
.process_cargos_comissao_detalhado <- function(n_max_comissoes) {
  comissoes <- read_csv(
    here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
    col_types = cols(id = "c")
  ) %>%
    select(
      id,
      casa,
      Presidente,
      `Primeiro Vice-presidente`,
      `Segundo Vice-presidente`,
      `Terceiro Vice-presidente`,
      Titular
    ) %>%
    gather(key = "cargo", value = "comissao", Presidente:Titular) %>% 
    filter(!is.na(comissao)) %>% 
    separate_rows(comissao, sep = ";") %>% 
    ungroup() %>% 
    group_by(id, casa, cargo) %>% 
    summarise(comissoes = n()) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(max_comissoes_casa = (n_max_comissoes %>% filter(casa_parlamentar == casa) %>% pull(max))) %>% 
    ungroup() %>% 
    spread(key = "cargo", value = "comissoes") %>% 
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(dplyr::everything()))
}

#' @description Recupera informações detalhadas dos cargos em lideranças para parlamentares
#' @return Dataframe com cargos em lideranças ocupados por parlamentares
.process_cargos_lideranca_detalhado <- function() {
  liderancas <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                         col_types = cols(id = "c")) %>% 
    select(id, casa, Líder, `Vice-líder`, `Representante`) %>%
    gather(key = "cargo", value = "partido", Líder:Representante) %>% 
    filter(!is.na(partido)) %>% 
    separate_rows(partido, sep = ";") %>% 
    ungroup() %>% 
    group_by(id, casa, cargo) %>% 
    summarise(liderancas = n()) %>% 
    ungroup() %>% 
    spread(key = "cargo", value = "liderancas") %>% 
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(dplyr::everything()))
}

#' @description Recupera informações detalhadas dos cargos na Mesa Diretora para parlamentares
#' @return Dataframe com cargos na Mesa Diretora ocupados por parlamentares
.process_cargos_mesa_detalhado <- function() {
  source(here("parlametria/crawler/cargos_mesa/fetcher_cargos_mesa.R"))
  
  cargos_mesa_camara <- fetch_cargos_mesa_camara(legislatura = 56, atual_cargo = TRUE) %>% 
    mutate(casa = "camara")
  
  cargos_mesa_senado <- fetch_cargos_mesa_senado() %>% 
    mutate(casa = "senado")
  
  cargos_mesa_detalhado <- cargos_mesa_camara %>% 
    rbind(cargos_mesa_senado) %>% 
    mutate(id = as.character(id)) %>% 
    select(id, casa, cargo) %>% 
    mutate(cargo = case_when(
      str_detect(cargo, "Suplente de Secretário") ~ "Suplente de Secretário",
      str_detect(cargo, "Secretário") ~ "Secretário",
      str_detect(cargo, "Vice-Presidente") ~ "Vice-Presidente",
      str_detect(cargo, "Presidente") ~ "Presidente",
      TRUE ~ "")) %>% 
    filter(cargo != "") %>% 
    group_by(id, casa, cargo) %>% 
    summarise(cargo_mesa = n()) %>% 
    ungroup() %>% 
    spread(key = "cargo", value = "cargo_mesa") %>% 
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(dplyr::everything()))
}



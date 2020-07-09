#' @title Calcula 
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.

#' @title Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @description Processa e cruza dados de atuação dos parlamentares para construção de um índice de influência
#' @return Dataframe contendo variáveis utilizadas para construção de índice de influência.
process_indice_influencia_parlamentar <- function() {
  library(tidyverse)
  library(here)
  options(scipen=999)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(em_exercicio == 1)
  
  parlamentares_id <- parlamentares %>% 
    select(id, casa)
  
  movimentos_renovacao <- read_csv(here("parlametria/crawler/movimentos_renovacao/movimentos_renovacao.csv"),
                                   col_types = cols(id = "c")) %>% 
    mutate(casa = case_when(
      str_detect(cargo, "Deputad") ~ "camara",
      str_detect(cargo, "Senad") ~ "senado",
      TRUE ~ NA_character_
    )) %>% 
    select(id, casa, grupos) %>% 
    mutate(participou_movimento_renovacao = if_else(is.na(grupos), 0, 1)) %>% 
    select(-grupos)
  
  investimento_partidario <- read_csv(here("parlametria/raw_data/resumo/parlamentares_investimento.csv"),
                                      col_types = cols(id = "c")) %>% 
    filter(sg_partido == partido_eleicao,
           em_exercicio == 1) %>% 
    select(id, casa, investimento_partidario = proporcao_campanhas_medias_receita) %>% 
    distinct() %>% 
    mutate(
      investimento_partidario = sqrt(investimento_partidario)/sqrt(max(investimento_partidario)))
  
  mandatos_cargos <- read_csv(here("parlametria/raw_data/cargos_politicos/historico_parlamentares_cargos_politicos.csv"),
                              col_types = cols(id_parlamentar = "c")) %>% 
    group_by(id_parlamentar, casa) %>% 
    summarise(numero_de_mandatos = n_distinct(ano_eleicao)) %>% 
    ungroup() %>% 
    mutate(numero_de_mandatos = (numero_de_mandatos - 1) / (max(numero_de_mandatos) - 1) )
  
  n_max_comissoes <-  read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                               col_types = cols(id = "c")) %>% 
    select(id, casa, Titular) %>% 
    separate_rows(Titular, sep = ";") %>% 
    filter(!is.na(Titular)) %>% 
    count(id, casa) %>% 
    group_by(casa) %>% 
    summarise(max = max(n)) %>% 
    rename(casa_parlamentar = casa)
    
  indice_comissoes_cargos <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                     col_types = cols(id = "c")) %>% 
    select(id,
           casa,
           Presidente, 
           `Primeiro Vice-presidente`,
           `Segundo Vice-presidente`, 
           `Terceiro Vice-presidente`,
           Titular) %>% 
    gather(key = "cargo", value = "comissao", Presidente:Titular) %>% 
    filter(!is.na(comissao)) %>% 
    separate_rows(comissao, sep = ";") %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Presidente") ~ 1,
      str_detect(cargo, "Primeiro Vice-presidente") ~ 0.3,
      str_detect(cargo, "Segundo Vice-presidente") ~ 0.1,
      str_detect(cargo, "Terceiro Vice-presidente") ~ 0.05,
      str_detect(cargo, "Titular") ~ 0 / (n_max_comissoes %>% filter(casa_parlamentar == casa) %>% pull(max))
    )) %>% 
    ungroup() %>% 
    group_by(id, casa) %>% 
    summarise(score_comissoes = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_comissoes = score_comissoes / max(score_comissoes)) %>% 
    select(id, casa, indice_comissoes)
    
  lideranca_partido <- read_csv(here("parlametria/raw_data/resumo/parlamentares_cargos.csv"),
                                     col_types = cols(id = "c")) %>% 
    select(id, casa, Líder, `Vice-líder`, `Representante`) %>%
    gather(key = "cargo", value = "partido", Líder:Representante) %>% 
    filter(!is.na(partido)) %>% 
    separate_rows(partido, sep = ";") %>% 
    mutate(peso = case_when(
      str_detect(cargo, "Líder") ~ 3,
      str_detect(cargo, "Vice-líder") ~ 0,
      str_detect(cargo, "Representante") ~ 3
    )) %>% 
    group_by(id, casa) %>% 
    summarise(score_liderancas = sum(peso)) %>% 
    ungroup() %>% 
    mutate(indice_liderancas = score_liderancas / max(score_liderancas)) %>% 
    select(id, casa, indice_liderancas)
  
  source(here("parlametria/crawler/cargos_mesa/fetcher_cargos_mesa.R"))
  
  cargos_mesa_camara <- fetch_cargos_mesa_camara(legislatura = 56, atual_cargo = TRUE) %>% 
    mutate(casa = "camara")
  
  cargos_mesa_senado <- fetch_cargos_mesa_senado() %>% 
    mutate(casa = "senado")
  
  cargos_mesa <- cargos_mesa_camara %>% 
    rbind(cargos_mesa_senado) %>% 
    mutate(id = as.character(id)) %>% 
    mutate(indice_cargo_mesa = case_when(
      str_detect(cargo, "Suplente de Secretário") ~ 0,
      str_detect(cargo, "Secretário") ~ 3,
      str_detect(cargo, "Vice-Presidente") ~ 1,
      str_detect(cargo, "Presidente") ~ 7,
      TRUE ~ 0)) %>% 
    mutate(indice_cargo_mesa = indice_cargo_mesa / max(indice_cargo_mesa)) %>% 
    select(id, casa, indice_cargo_mesa)
  
  ## TODO: porcentagem dos votos recebidos em 2018 com relação a UF e ao partido
  
  parlamentares_processed <- parlamentares_id %>% 
    left_join(movimentos_renovacao, by = c("id", "casa")) %>% 
    left_join(investimento_partidario, by = c("id", "casa")) %>% 
    left_join(mandatos_cargos, by = c("id" = "id_parlamentar", "casa" = "casa")) %>% 
    left_join(indice_comissoes_cargos, by = c("id", "casa")) %>% 
    left_join(lideranca_partido, by = c("id", "casa")) %>% 
    left_join(cargos_mesa, by = c("id", "casa")) %>% 
    ## Substituindo NA por 0
    mutate_at(.funs = list(~replace_na(., 0)), .vars = vars(participou_movimento_renovacao,
                                                            investimento_partidario,
                                                            indice_comissoes,
                                                            indice_liderancas,
                                                            indice_cargo_mesa)
              ) %>% 
    ## Substituindo NA no número de mandatos por 1 (parlamentar está em exercício apesar da suplência)
    mutate(numero_de_mandatos = ifelse(is.na(numero_de_mandatos), 1, numero_de_mandatos)) %>% 
    mutate(indice_influencia_parlamentar = 
             (investimento_partidario*2 + indice_liderancas*4 + indice_comissoes*2 + indice_cargo_mesa*6 + numero_de_mandatos*1) / 15) %>%  ## 15 é a soma dos pesos (2+4+2+6+1)
    mutate(indice_influencia_parlamentar = indice_influencia_parlamentar / max(indice_influencia_parlamentar))

  return(parlamentares_processed)
}

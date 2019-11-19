#' @title Realiza merge entre lista de parlamentares da câmara/senado e dados do perfil político (Open Knowledge)
#' @description Reliza merge com condições especiais entre a lista de parlamentares da câmara/senado e dados
#' do perfil político (https://github.com/okfn-brasil/perfil-politico)
#' @param parlamentares_merge_alternativo Dataframe com parlamentares vindo da Câmara/Senado.
#' Colunas necessárias: id, casa, cpf, nome_eleitoral, uf, sg_partido, data_nascimento, em_exercicio, partido_eleicao,
#' nome_urna, nome_urna_processed, partido_eleicao_processed
#' @param perfil_politico Dataframe com informações do perfil político. Colunas necessárias:
#' id_perfil_politico, nome, partido, uf, cargo
#' @return Dataframe com informações dos parlamentares e de seu perfil político (id)
processa_merge_parlamentares_api_perfil_politico <- function(parlamentares_merge_alternativo, perfil_politico) {
  library(tidyverse)
  library(fuzzyjoin)
  
  parlamentares_selected <- parlamentares_merge_alternativo %>%
    select(id, casa, cpf, nome_eleitoral, uf, sg_partido, data_nascimento, em_exercicio, partido_eleicao,
           nome_urna, nome_urna_processed, partido_eleicao_processed)

  ## merge considerando primeiro e último nome
  parlamentares_merge_alt <- parlamentares_selected %>% 
    mutate(nome_urna_processed = paste0(stringr::word(nome_urna_processed, 1), 
                                         " ",
                                         stringr::word(nome_urna_processed, -1))) %>% 
    left_join(perfil_politico %>% 
                mutate(partido = if_else(partido == "SD", "SOLIDARIEDADE", partido)) %>% ## trata caso de abreviação usada e substitui pelo nome
                mutate(nome_processed = padroniza_nome(nome),
                       partido_processed = padroniza_nome(partido),
                       nome_processed = paste0(stringr::word(nome_processed, 1), 
                                               " ",
                                               stringr::word(nome_processed, -1))) %>% 
                mutate(nome_processed =
                         case_when(
                           nome_processed == "MARCIO LEMOS" ~ "CORONEL TADEU",
                           nome_processed == "DRA. MILANE" ~ "DRA. MILANI",
                           nome_processed == "DELEGADO LATERCA" ~ "FELICIO LATERCA",
                           nome_processed == "HELIO BOLSONARO" ~ "HELIO LOPES",
                           nome_processed == "MOTTA MOTTA" ~ "LUIZ MOTTA",
                           nome_processed == "JUNIOR MARRECA FILHO" ~ "JUNIOR MARRECA FILHO", ## sem correspondência
                           nome_processed == "REINHOLD JUNIOR" ~ "STEPHANES JUNIOR",
                           nome_processed == "RONALDO SANTINI" ~ "SANTINI SANTINI",
                           nome_processed == "SILVO FILHO" ~ "SILVIO FILHO",
                           nome_processed == "EDUARDO GOMES" ~ "EDUARDO GOMES", ## sem correspondência
                           nome_processed == "IRAJA ABREU" ~ "IRAJA IRAJA",
                           nome_processed == "ORIOVISTO GUIMARAES" ~ "PROFESSOR GUIMARAES",
                           TRUE ~ nome_processed
                         )), 
              by = c("nome_urna_processed" = "nome_processed",
                     "uf" = "uf",
                     "partido_eleicao_processed" = "partido_processed"))
  
  return(parlamentares_merge_alt)
}

#' @title Cria tabela com informações dos parlamentares presentes na API do perfil político 
#' @description Cria tabela com informações dos parlamentares que também estão presentes na 
#' API do perfil político (https://github.com/okfn-brasil/perfil-politico)
#' @param candidatos_perfil_politico_data_path Caminho para o arquivo de dados dos candidatos do perfil político
#' @param parlamentares_data_path Caminho para o arquivo de dados de parlamentares da Câmara e do Senado
#' #' @param doacoes_path_2014 Caminho para o arquivo de candidatos (Câmara e Senado) em 2014 e suas respectivas doações
#' recebidas
#' @param doacoes_path_2018 Caminho para o arquivo de candidatos (Câmara e Senado) em 2018 e suas respectivas doações
#' recebidas
#' @return Dataframe com informações do perfil político
processa_perfil_politico <- 
  function(candidatos_perfil_politico_data_path = here::here("crawler/raw_data/candidatos_perfil_politico.csv"),
           parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv"),
           doacoes_path_2014 = here::here("parlametria/raw_data/receitas/candidatos_congresso_doadores_2014.csv"),
           doacoes_path_2018 = here::here("parlametria/raw_data/receitas/candidatos_congresso_doadores_2018.csv")) {
  
  library(tidyverse)
  library(here)
  source(here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_parlamentares.R"))
  source(here("crawler/utils/utils.R"))
  
  perfil_politico <- read_csv(candidatos_perfil_politico_data_path, col_types = cols(id = "c")) %>% 
    rename(id_perfil_politico = id)

  parlamentares <- read_csv(parlamentares_data_path, col_types = cols(id = "c"))
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf) %>% 
    distinct(id_senador, cpf_senador)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador)
  
  candidatos_tse_2018 <- read_csv(doacoes_path_2018, col_types = c(NR_CPF_CANDIDATO = "c")) %>% 
    distinct(NR_CPF_CANDIDATO, SG_PARTIDO, SG_UE, NM_URNA_CANDIDATO) %>% 
    select(cpf = NR_CPF_CANDIDATO, partido_eleicao = SG_PARTIDO, uf_eleicao = SG_UE, nome_urna = NM_URNA_CANDIDATO)
  
  candidatos_tse_2014 <- read_csv(doacoes_path_2014, col_types = c(NR_CPF_CANDIDATO = "c")) %>% 
    distinct(NR_CPF_CANDIDATO, SG_PARTIDO, SG_UE, NM_URNA_CANDIDATO) %>% 
    select(cpf = NR_CPF_CANDIDATO, partido_eleicao = SG_PARTIDO, uf_eleicao = SG_UE, nome_urna = NM_URNA_CANDIDATO)
  
  candidatos_tse_2014 <- candidatos_tse_2014 %>% 
    anti_join(candidatos_tse_2018,
              by = "cpf")
  
  candidatos_tse <- candidatos_tse_2018 %>% 
    rbind(candidatos_tse_2014)

  parlamentares_merge <- parlamentares %>% 
    select(id, casa, cpf, nome_eleitoral, uf, sg_partido, data_nascimento, em_exercicio) %>% 
    left_join(candidatos_tse, by = c("cpf")) %>% 
    select(id, casa, cpf, nome_eleitoral, uf, sg_partido, data_nascimento, em_exercicio, partido_eleicao, nome_urna)
  
  parlamentares_merge_perfil <- parlamentares_merge %>% 
    mutate(nome_urna_processed = padroniza_nome(nome_urna),
           partido_eleicao_processed = padroniza_nome(partido_eleicao)) %>% 
    left_join(perfil_politico %>% 
                mutate(nome_processed = padroniza_nome(nome),
                       partido_processed = padroniza_nome(partido)), 
              by = c("nome_urna_processed" = "nome_processed",
                     "uf" = "uf",
                     "partido_eleicao_processed" = "partido_processed"))
    
  parlamentares_merge_completo <- parlamentares_merge_perfil %>% 
    filter(em_exercicio == 1, !is.na(id_perfil_politico))
  
  parlamentares_merge_alternativo <- parlamentares_merge_perfil %>% 
    filter(em_exercicio == 1, is.na(id_perfil_politico)) %>% 
    processa_merge_parlamentares_api_perfil_politico(perfil_politico)
  
  parlamentares_alt <- parlamentares_merge_completo %>% 
    rbind(parlamentares_merge_alternativo)
  
  parlamentares_distinct <- parlamentares_alt %>% 
    group_by(id, casa) %>% 
    summarise(cpf = first(cpf),
              nome_eleitoral = first(nome_eleitoral),
              uf = first(uf), 
              sg_partido = first(sg_partido),
              em_exercicio = first(em_exercicio),
              id_perfil_politico = max(id_perfil_politico)) %>% 
    ungroup()
  
  parlamentares_voz_ativa_perfil_politico <- parlamentares_distinct %>% 
    mutate(casa_enum = dplyr::if_else(casa == "camara", 1, 2),
           id_parlamentar_voz = paste0(casa_enum, as.character(id))) %>% 
    select(id_parlamentar_voz, casa, cpf, nome_eleitoral, uf, sg_partido, em_exercicio, id_perfil_politico)
  
  return(parlamentares_voz_ativa_perfil_politico)
}

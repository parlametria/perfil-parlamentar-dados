#' @title Retorna os parlamentares que são membros das frentes "mais progressistas"
#' @description Retorna os parlamentares que são membros das frentes mais progressistas e
#' calcula a média dessas 5 frentes.
#' @return Dataframe dos parlamentares com o combo das frentes "progressistas"
frentes_mais_progressistas <- function() {
  library(tidyverse)
  
  titulos_frentes_mais_ambientalistas <- c(
    "Frente Parlamentar Ambientalista", 
    "Frente Parlamentar Mista em Apoio aos Objetivos de Desenvolvimentos Sustentáveis da ONU - ODS", 
    "Frente Parlamentar em Favor do Pagamento por Serviços Ambientais e Produção Sustentável", 
    "Frente Parlamentar Mista em Defesa das Organizações da Sociedade Civil - OSCs",
    "Frente Parlamentar Mista em Defesa dos Direitos dos Povos Indígenas")
  
  frentes_mais_ambientalistas <- read_csv(here("parlametria/raw_data/frentes/frentes.csv")) %>% 
    filter(titulo_frente %in% titulos_frentes_mais_ambientalistas) %>% 
    distinct(id_frente) %>% 
    pull(id_frente)
  
  membros <- read_csv(here::here("parlametria/raw_data/frentes/membros_frentes.csv")) %>% 
    filter(id_frente %in% frentes_mais_ambientalistas, !is.na(id)) %>% 
    select(id, id_frente) %>% 
    count(id) %>% 
    mutate(combo_5_frentes_progressistas = n / 5) %>% 
    select(-n)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(em_exercicio == 1, casa == "camara") %>% 
    select(id)
  
  membros <- membros %>% 
    inner_join(parlamentares, by = "id")
  
  return(membros)
}

#' @title Retorna os parlamentares que são membros das frentes "mais ruralistas"
#' @description Retorna os parlamentares que são membros das frentes: agropecuária, mineração e 
#' livre mercado e calcula a média do combo das três frentes.
#' @return Dataframe dos parlamentares membros de frentes "ruralistas"
frentes_ruralistas <- function() {
  
  library(tidyverse)
  
  titulos_frentes_ruralistas <- c(
    "Frente Parlamentar da Agropecuária - FPA",
    "Frente Parlamentar Mista da Mineração", 
    "Frente Parlamentar pelo Livre Mercado")
  
  frentes_ruralistas <- read_csv(here("parlametria/raw_data/frentes/frentes.csv")) %>% 
    filter(titulo_frente %in% titulos_frentes_ruralistas) %>% 
    distinct(id_frente, titulo_frente)
  
  membros <- read_csv(here::here("parlametria/raw_data/frentes/membros_frentes.csv")) %>% 
    inner_join(frentes_ruralistas, by = "id_frente") %>% 
    select(id, titulo_frente) %>% 
    spread(titulo_frente, titulo_frente) %>% 
    rename(frente_agropecuaria = `Frente Parlamentar da Agropecuária - FPA`,
           frente_mineracao = `Frente Parlamentar Mista da Mineração`,
           frente_livre_mercado = `Frente Parlamentar pelo Livre Mercado`) %>% 
    mutate(frente_agropecuaria = if_else(is.na(frente_agropecuaria), 0, 1),
           frente_mineracao = if_else(is.na(frente_mineracao), 0, 1),
           frente_livre_mercado = if_else(is.na(frente_livre_mercado), 0, 1)) %>% 
    group_by(id) %>% 
    mutate(combo_agro_mineracao_lm = sum(frente_agropecuaria, frente_mineracao, frente_livre_mercado) / 3)
  
  parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(em_exercicio == 1, casa == "camara") %>% 
    select(id)
  
  membros <- membros %>% 
    inner_join(parlamentares, by = "id")
  
  return(membros)
}

#' @title Retorna as informações sobre o índice de ativismo ambiental dos parlamentares
#' @description Calcula e retorna o índice de ativismo para cada parlamentar, baseado em 
#' ((combo_5_frentes_progressistas - combo_agro_mineracao_lm) + proposicoes_meio_ambiente_indice +
#'  discurso_normalizado + requerimentos_informacao_agro_mma_indice + aderencia) / 5
#' @return Dataframe com o índice de ativismo ambiental e as demais colunas necessárias para seu
#' cálculo.
process_indice_ativismo_ambiental <- function() {
  library(tidyverse)
  library(here)
  
  parlamentares <-
    read_csv(here("crawler/raw_data/parlamentares.csv")) %>%
    filter(em_exercicio == 1) %>%
    select(id, casa)
  
  # Discursos analisados pela RAC
  discursos_rac <-
    read_csv(here::here(
      "parlametria/raw_data/discursos_rac/discursos_parlamentares.csv"
    ))
  
  # Aderência ao meio ambiente
  aderencia <-
    read_csv(here("parlametria/raw_data/resumo/parlamentares_aderencia.csv")) %>%
    select(id, casa, aderencia) %>%
    mutate(aderencia = if_else(aderencia == -1 |
                                 is.na(aderencia), 0, 1 - aderencia))
  
  # Proposições do Meio Ambiente
  autores_meio_ambiente <- read_csv(here("parlametria/raw_data/autorias/atores_meio_ambiente.csv")) %>% 
    group_by(id_autor) %>% 
    summarise(
      tipo_autor = first(tipo_autor),
      qtd_total_de_documentos = sum(qtd_de_documentos)
    ) %>% 
    rename(id = id_autor, proposicoes_meio_ambiente = qtd_total_de_documentos) %>% 
    mutate(proposicoes_meio_ambiente_indice = case_when(proposicoes_meio_ambiente > 10 ~ 1,
                                                        proposicoes_meio_ambiente >= 2 ~ 0.5,
                                                        proposicoes_meio_ambiente == 1 ~ 0.25,
                                                        TRUE ~ 0)) %>% 
    mutate(casa_parlamentar = if_else(tipo_autor == "deputado", "camara", "senado")) %>% 
    select(id, casa = casa_parlamentar, proposicoes_meio_ambiente_indice)
    
  
  # Requerimentos de informação sobre MMA e agricultura
  autores_req_info_mma_agricultura <- 
    read_csv(here("parlametria/raw_data/autorias/req_info_meio_ambiente_agricultura.csv")) %>% 
    mutate(requerimentos_informacao_agro_mma_indice = 
             case_when(num_req_informacao > 10 ~ 1,
                       num_req_informacao > 1 ~ 0.5,
                       num_req_informacao == 1 ~ 0.25,
                       TRUE ~ 0)) %>% 
    select(id, casa, requerimentos_informacao_agro_mma_indice)
  
 
  # 5 frentes mais ambientalistas
  membros_frentes_ambientalistas <- frentes_mais_progressistas() %>% 
    mutate(casa = "camara")
  
  # Combo frentes agropecuária, mineração e livre mercado
  membros_agro_mineracao_lm <- frentes_ruralistas() %>% 
    mutate(casa = "camara")
  
  indice_ativismo_ambiental <- parlamentares %>%
    left_join(membros_agro_mineracao_lm, by = c("id", "casa")) %>%
    left_join(membros_frentes_ambientalistas, by = c("id", "casa")) %>%
    left_join(discursos_rac, by = c("id", "casa")) %>%
    left_join(aderencia, by = c("id", "casa")) %>%
    left_join(autores_meio_ambiente, by = c("id", "casa")) %>%
    left_join(autores_req_info_mma_agricultura, by = c("id", "casa")) %>%
    mutate_at(
      .funs = list(~ replace_na(., 0)),
      .vars = vars(
        frente_agropecuaria,
        frente_mineracao,
        frente_livre_mercado,
        combo_5_frentes_progressistas,
        combo_agro_mineracao_lm,
        proposicoes_meio_ambiente_indice,
        discurso_normalizado,
        aderencia,
        requerimentos_informacao_agro_mma_indice
      )
    ) %>%
    mutate(
      indice_ativismo_ambiental =
        ((combo_5_frentes_progressistas - combo_agro_mineracao_lm) +
           proposicoes_meio_ambiente_indice * 4 +
           discurso_normalizado * 1.5 +
           requerimentos_informacao_agro_mma_indice * 2 +
           aderencia * 3
        ) / 11.5
    )
  
  return(indice_ativismo_ambiental)
}
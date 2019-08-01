#!/usr/bin/env Rscript
source(here::here("crawler/votacoes/utils/constants.R"))
source(here::here("crawler/parlamentares/deputados/fetcher_deputado.R"))

# Bibliotecas
library(tidyverse)
library(rcongresso)

#' @title Processa votações e informações dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes Dataframe com informações das votações para captura dos votos
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados
#' @examples
#' processa_votos_camara(votacoes)
processa_votos_camara <- function(votacoes) {
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  source(here::here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  
  proposicao_votacao <- votacoes %>% 
    dplyr::filter(!is.na(id_sessao)) %>% 
    dplyr::select(numero_proj_lei, id_proposicao, id_sessao, resumo, objeto_votacao)

  votos <- purrr::pmap_dfr(list(proposicao_votacao$id_proposicao, 
                                proposicao_votacao$numero_proj_lei,
                                proposicao_votacao$id_sessao, 
                                proposicao_votacao$resumo,
                                proposicao_votacao$objeto_votacao), 
                    ~ fetch_votos_por_votacao_camara(..1, ..2, ..3, ..4, ..5))

  parlamentares_filepath = here::here("crawler/raw_data/parlamentares.csv")
  
  if(file.exists(parlamentares_filepath)) {
    parlamentares <- readr::read_csv(parlamentares_filepath)
    
  } else {
    # IDS das últimas duas legislaturas
    legislaturas_list <- c(55,56)
    parlamentares <- purrr::map_df(legislaturas_list, ~ fetch_deputados(.x))
  }

  votos_alt <- votos %>% 
    dplyr::mutate(casa = "camara") %>%
    dplyr::select(id_proposicao, id_votacao, id_parlamentar = id_deputado, casa, partido, voto) %>% 
    enumera_voto() %>% 
    dplyr::distinct()

  return(votos_alt)
}

#' @title Processa votações dos parlamentares
#' @description O processamento consiste em mapear as votações dos parlamentares (caso tenha votado) e tratar os casos quando ele não votou
#' @param url Link para o csv com as posições do questionário do Voz Ativa
#' @return Dataframe contendo o id da votação, o id do parlamentar, a casa e o voto dos parlamentares
#' @examples
#' processa_votos(url)
processa_votos <- function(url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTMcbeHRm_dqX-i2gNVaCiHMFg6yoIjNl9cHj0VBIlQ5eMX3hoHB8cM8FGOukjfNajWDtfvfhqxjji7/pub?gid=0&single=true&output=csv") {
  votacoes_lista <- read_csv(url, col_types = cols(id_proposicao = "c"))
    # filter(status_proposicao == "Ativa") %>% 
    # filter(id_sessao != 99999) # remove votacao da PL 6299/2002 (nao possui votacoes em plenário)
  
  votacoes_camara <- votacoes_lista %>% 
    dplyr::filter(tolower(iconv(casa, 
                        from = "UTF-8", 
                        to = "ASCII//TRANSLIT")) == "camara")
  
  votacoes_senado <- votacoes_lista %>% 
    dplyr::filter(casa == "senado")
  
  votacoes <- processa_votos_camara(votacoes_camara) %>% 
    select(id_proposicao, id_votacao, id_parlamentar, casa, voto)
  
  return(votacoes)
}

#' @title Processa votos de proposições votadas em plenário para um determinado ano
#' @description Recupera informação dos votos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @param url Link para dados das proposições selecionadas para captura das votações em plenário
#' Se url é diferente de NULL, então considerará lista de proposições presentes nos dados disponíveis através da URL
#' @return Dataframe com informações dos votos
#' @examples
#' votos <- process_votos_por_ano_camara(2019)
process_votos_por_ano_camara <- function(ano = 2019, url = NULL) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
  source(here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- tryCatch({
    fetch_proposicoes_votadas_por_ano_camara(ano)
  }, error = function(e) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  })
  
  if (!is.null(url)) {
    proposicoes_selecionadas <- read_csv(url, col_types = cols(id = "c")) %>% 
      filter(tolower(tema_va) != "não entra") %>% 
      select(id, nome_proposicao = nome)
    
    proposicoes_votadas <- proposicoes_votadas %>% 
      filter(id %in% (proposicoes_selecionadas %>% pull(id)))
  }
  
  ## checa se existem proposições com dados de votações em plenário para aquele ano
  if (nrow(proposicoes_votadas) == 0) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  }
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  votos <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_votos_por_ano_camara, 
      ano
    )) %>% 
    unnest(dados) %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    distinct() 
  
  return(votos)
}

#' @title Processa votos e orientação de proposições (selecionadas pela equipe VA) votadas em plenário para um conjunto de anos
#' @description Recupera informação dos votos e das orientações dos partidos para um conjunto de anos para as 
#' proposicoes selecionadas pela equipe VA.
#' @param anos Vector com lista de anos
#' @return Lista contendo dois dataframes: votos e orientações
#' @examples
#' votos <- process_votos_anos_url_camara(2019)
process_votos_anos_url_camara <- function(anos = c(2019, 2020, 2021, 2022),
                                              url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSvvT0fmGUMwOHnEPe9hcAMC_l-u9d7sSplNYkMMzgiE_vFiDcWXWwl4Ys7qaXuWwx4VcPtFLBbMdBd/pub?gid=399933255&single=true&output=csv") {
  library(tidyverse)
  
  votos <- tibble(ano = anos) %>%
    mutate(dados = map(
      ano,
      process_votos_por_ano_camara,
      url
    )) %>% 
    unnest(dados) %>% 
    distinct() %>% 
    rename(id_parlamentar = id_deputado) %>% 
    mutate(casa = "camara")
  
  return(votos)
}

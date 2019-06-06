#' @title Processa votos e orientação de proposições votadas em plenário para um determinado ano
#' @description Recupera informação dos votos e das orientações dos partidos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @return Lista contendo dois dataframes: votos e orientações
#' @examples
#' votos_orientacao <- process_votos_orientacao(2019)
process_votos_orientacao <- function(ano = 2019) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/fetch_orientacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- fetch_votacoes_ano(ano)
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  ## checa se existem proposições com dados de votações em plenário para aquele ano
  if (is.na(id_proposicao)) {
    data <- list()
    return(data)
  }
  
  votos <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_votacoes_por_ano, 
      ano
    )) %>% 
    unnest(dados) %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    distinct() 
  
  orientacao <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_orientacoes_por_proposicao, 
      ano
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(list(votos, orientacao))
}

#' @title Processa votos de proposições votadas em plenário para um determinado ano
#' @description Recupera informação dos votos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @return Dataframe com informações dos votos
#' @examples
#' votos <- process_votos_orientacao(2019)
process_votos_por_ano <- function(ano = 2020) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/fetch_orientacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- tryCatch({
    fetch_votacoes_ano(ano)
  }, error = function(e) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  })
  
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
      fetch_votacoes_por_ano, 
      ano
    )) %>% 
    unnest(dados) %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    distinct() 
  
  return(votos)
}

#' @title Processa orientação de proposições votadas em plenário para um determinado ano
#' @description Recupera informação das orientações dos partidos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @return Dataframe com informações das orientações
#' @examples
#' orientacao <- process_orientacao_por_ano(2019)
process_orientacao_por_ano <- function(ano = 2019) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/fetch_orientacoes.R"))
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- tryCatch({
    fetch_votacoes_ano(ano)
  }, error = function(e) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ partido, ~ voto)
    return(data)
  })
  
  ## checa se existem proposições com dados de votações em plenário para aquele ano
  if (nrow(proposicoes_votadas) == 0) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ partido, ~ voto)
    return(data)
  }
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  orientacao <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_orientacoes_por_proposicao, 
      ano
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(orientacao)
}

#' @title Processa votos e orientação de proposições votadas em plenário para um conjunto de anos
#' @description Recupera informação dos votos e das orientações dos partidos para um conjunto de anos
#' @param anos Vector com lista de anos
#' @return Lista contendo dois dataframes: votos e orientações
#' @examples
#' votos_orientacao <- process_votos_orientacao(2019)
process_votos_orientacao_anos <- function(anos = c(2019, 2020, 2021, 2022)) {
  library(tidyverse)
  
  votos <- tibble(ano = anos) %>%
    mutate(dados = map(
      ano,
      process_votos_por_ano
    )) %>% 
    unnest(dados) %>% 
    distinct() %>% 
    rename(id_parlamentar = id_deputado) %>% 
    mutate(casa = "camara")
  
  orientacao <- tibble(ano = anos) %>%
    mutate(dados = map(
      ano,
      process_orientacao_por_ano
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(list(votos, orientacao))
}

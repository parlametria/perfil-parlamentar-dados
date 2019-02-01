#!/usr/bin/env Rscript

# devtools::install_github('analytics-ufcg/rcongresso')
# install.packages("tm", repos="http://R-Forge.R-project.org")

# Bibliotecas
library(tidyverse)
library(rcongresso)
library(tm)

#' @title Enumera votações
#' @description Recebe um dataframe com coluna voto e enumera o valor para um número
#' @param df Dataframe com a coluna voto
#' @return Dataframe com coluna voto enumerada
#' @examples
#' enumera_votacoes(df)
enumera_votacoes <- function(df) {
  df %>%
    mutate(voto = case_when(str_detect(voto, "Não") ~ -1,
                            str_detect(voto, "Sim") ~ 1,
                            str_detect(voto, "Obstrução") ~ 2,
                            str_detect(voto, "Abstenção") ~ 3,
                            str_detect(voto, "Art. 17") ~ 4,
                            TRUE ~ 0))
}

#' @title Baixa dados dos votos das votações
#' @description Baixa os dados dos votos das votações, retornando um dataframe vazio caso a requisição não seja bem sucedida.
#' @param id_votacao id da votação
#' @return Dataframe informações sobre os votos e os parlamentares.
#' @examples
#' votos <- fetch_voto(7566)
fetch_voto <- function(id_votacao) {
  votos <- tryCatch({
    data <- rcongresso::fetch_votos(id_votacao)
  }, error = function(e) {
    data <- tribble(
      ~ id_votacao, ~ parlamentar.id, ~ parlamentar.idLegislatura,
      ~ parlamentar.nome, ~ parlamentar.siglaPartido,
      ~ parlamentar.siglaUf, ~ parlamentar.uri, ~ parlamentar.uriPartido,
      ~ parlamentar.urlFoto, ~ voto)

    return(data)
  })

  return(votos)
}

#' @title Baixa nome civil dos deputados
#' @description Baixa nome civil dos deputados pelo id do parlamentar na Câmara.
#' @param id_votacao id do deputado
#' @return Dataframe informações de id e nome civil.
#' @examples
#' deputado <- fetch_deputado(73874)
fetch_deputado <- function(id_deputado) {
  deputado <- tryCatch({
    data <- rcongresso::fetch_deputado(id_deputado) %>% 
      select(id, nomeCivil, cpf)
  }, error = function(e) {
    data <- tribble(
      ~ id, ~ nomeCivil)
    return(data)
  })
  
  return(deputado)
}

#' @title Importa dados de todos os deputados nas últimas 3 legislaturas
#' @description Importa os dados de todos os deputados federais das últimas 3 legislaturas: 54, 55 e 56.
#' @return Dataframe contendo informações dos deputados: id, nome civil e cpf
#' @examples
#' deputados <- fetch_deputados()
fetch_deputados <- function() {
  info_pessoais <- do.call("rbind", lapply(rcongresso::fetch_deputado(idLegislatura = 54, itens = -1)$id, 
                                           fetch_deputado)) %>% 
    rbind(do.call("rbind", lapply(rcongresso::fetch_deputado(idLegislatura = 55, itens = -1)$id, 
                                  fetch_deputado)))  %>% 
    rbind(do.call("rbind", lapply(rcongresso::fetch_deputado(idLegislatura = 56, itens = -1)$id, fetch_deputado)))
  
  return(info_pessoais)
}

#' @title Importa e processa dados de votações
#' @description Recebe um dataframe com os dados das votações das proposições
#' @param df Dataframe com os dados das votações
#' @return Dataframe contendo id da votação, nome de urna, nome completo e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- fetch_votos(df)
fetch_votos <- function(ids_votacoes) {
  votos <- rbind(do.call("rbind", lapply(ids_votacoes, fetch_voto))) %>%
    select(id_votacao, parlamentar.nome, parlamentar.id, voto)
  return (votos)
}

#' @title Processa votações e informações dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes_datapath Datapath do csv com os dados das votações
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados
#' @examples
#' processa_votos("../raw_data/tabela_votacoes.csv")
processa_votos <- function(votacoes_datapath) {
  ids_votacoes <- read_csv(votacoes_datapath, col_types = "cddccc")$id_proposicao %>% 
    unique() 
  
  votos <- fetch_votos(ids_votacoes)
  deputados <- fetch_deputados()
  votos <- votos %>% 
    left_join(deputados, by = c("parlamentar.id" = "id")) %>% 
    select(id_votacao, cpf, voto) %>% 
   enumera_votacoes()
  
  return(votos)
}
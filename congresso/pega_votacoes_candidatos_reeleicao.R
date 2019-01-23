#!/usr/bin/env Rscript

# devtools::install_github('analytics-ufcg/rcongresso')
# install.packages("tm", repos="http://R-Forge.R-project.org")

# Bibliotecas
library(tidyverse)
library(rcongresso)
library(tm)
library(stringr)

#' @title Enumera votações
#' @description Recebe um voto e retorna um valor correspondente
#' @param voto Dado sobre um voto 
#' @return valor correspondente ao voto de entrada
#' @examples
#' enumera_votacoes("Não")
enumera_votacoes <- Vectorize(function(voto) {
  voto <- as.character(voto)
  switch (voto,
          "Não" = -1,
          "Sim" = 1,
          "NA" = 0,
          "null" = 0,
          "Obstrução" = 2,
          "Abstenção" = 3,
          "Art. 17" = 4,
          "-" = 0
  )
})

#' @title Padroniza nomes dos deputados
#' @description Padroniza os nomes dos candidatos, como remoção de stopwords, acentos, apóstrofes e conversão para caixa alta.
#' @param df Dataframe com os dados dos candidatos
#' @return Dataframe contendo cpf e o nome padronizado dos candidatos.
#' @examples
#' processa_nome_parlamentar(df)
processa_nome_parlamentar <- function(df) {
  # Remove stopwords dos nomes dos candidatos/deputados
  stopwords_regex <- paste(toupper(stopwords('pt')), collapse = '\\b|\\b')
  stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')
  
  # Tratamento de string - Remove acentuação, apóstrofes, deixa todos maiúsculos e remove
  # stopwords
  df %>%
    mutate(nome_candidato = toupper(iconv(nome_candidato, to="ASCII//TRANSLIT"))) %>%
    mutate(nome_candidato = str_replace_all(nome_candidato, stopwords_regex, "")) %>%
    mutate(nome_candidato = str_replace_all(nome_candidato, "  "," ")) %>%
    mutate(nome_candidato = str_replace_all(nome_candidato, "'","")) %>% 
    mutate(nome_candidato = gsub("(^[[:space:]]+|[[:space:]]+$)", "", nome_candidato))
}

#' @title Importa e processa dados de candidatos
#' @description Importa e processa os dados dos candidatos, como remoção de stopwords, acentos, apóstrofes e conversão para caixa alta.
#' @param df Dataframe com os dados dos candidatos
#' @return Dataframe contendo cpf e o nome processado dos candidatos.
#' @examples
#' candidatos <- processa_candidatos(df)
processa_candidatos <- function(df) {
  candidatos <- df %>% 
    select(nome_candidato, cpf_candidato) %>% 
    unique() %>% 
    processa_nome_parlamentar() %>% 
    rename(cpf = cpf_candidato) %>% 
    group_by(cpf) %>% 
    distinct()
  
  return (candidatos)
}

#' @title Importa e processa dados de votações
#' @description Recebe um dataframe com os dados das votações das proposições
#' @param df Dataframe com os dados das votações
#' @return Dataframe contendo id da votação, nome de urna, nome completo e voto dos deputados que participaram de cada votação
#' @examples
#' votacoes <- processa_votacoes(df)
processa_votacoes <- function(df) {
  ids_votacoes <- df$id_votacao
  deputados20142018_id <- fetch_deputado(idLegislatura = 55, itens = -1)$id
  deputados20102014_id <- fetch_deputado(idLegislatura = 54, itens = -1)$id
  
  info_pessoais_20102014 <- fetch_deputado(deputados20102014_id) %>% 
    select(id, nomeCivil)
  
  info_pessoais_20142018 <- fetch_deputado(deputados20142018_id) %>% 
    select(id, nomeCivil)
  
  ids <- ids_votacoes[1:15]
  ids2 <- ids_votacoes[16:34]
  
  votos <- fetch_votos(ids) %>% 
    dplyr::bind_rows(fetch_votos(ids2)) %>%
    select(id_votacao, parlamentar.nome, parlamentar.id, voto) %>% 
    left_join(info_pessoais_20142018, by= c("parlamentar.id" = "id")) %>%
    left_join(info_pessoais_20102014, by= c("parlamentar.id" = "id")) %>%
    mutate(nome_candidato = ifelse(is.na(nomeCivil.x), nomeCivil.y, nomeCivil.x)) %>%
    processa_nome_parlamentar() %>% 
    select(-nomeCivil.x, -nomeCivil.y)
  
  return (votos)
}

#' @title Filtra candidatos reeleitos
#' @description Recebe um dataframe com os dados dos candidatos
#' @param df Dataframe com os dados dos candidatos
#' @return Dataframe contendo os cpf's dos candidatos reeleitos
#' @examples
#' votacoes <- filtra_candidatos_reeleitos(candidatos)
filtra_candidatos_reeleitos <- function(df) {
  df %>%
    mutate(situacao_reeleicao = 
             if_else(situacao_reeleicao == 'S', 1, 0)) %>% 
    filter(situacao_reeleicao == 1) %>%
    select(cpf = cpf_candidato) %>% 
    unique()
}

#' @title Pega candidatos faltantes - que estão no voz ativa e não estã na câmara
#' @description Recebe um dataframe com os dados dos candidatos
#' @param candidatos_df Dataframe com os dados dos candidatos
#' @param candidatos_e_votos_df Dataframe com os dados dos votos
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados que estão no voz ativa e não estão na câmara
#' @examples
#' candidatos_faltantes_df <- candidatos_faltantes(candidatos_df, candidatos_e_votos_df)
candidatos_faltantes <- function(candidatos_df, candidatos_e_votos_df) {
  # CPFs dos candidatos a reeleição na plataforma voz ativa
  cpfs_voz <- filtra_candidatos_reeleitos(candidatos_df)
  
  # CPFs dos deputados que votaram na câmara 
  cpf_completos <- candidatos_e_votos_df %>% 
    select(cpf) %>%  
    unique()
  
  # CPFs dos deputados que estão no voz ativa e não estão na câmara
  faltantes <- cpfs_voz[!(cpfs_voz$cpf %in% cpf_completos$cpf),] %>% 
    as.data.frame() %>% 
    mutate(id_votacao = 4968, voto = "-") %>% 
    select(id_votacao, voto, cpf)
  
  return(faltantes)
}

#' @title Junta as informações dos votos com os dados cadastrais dos deputados
#' @description Recebe um dataframe com os dados dos candidatos
#' @param candidatos_df Dataframe com os dados dos candidatos
#' @param votos_df Dataframe com os dados das votações
#' @return Dataframe contendo o id da votação, o cpf, nome e o voto dos deputados
#' @examples
#' votos_tratados_df <- candidatos_join_votos(candidatos_df, votos_df)
candidatos_join_votos <- function(candidatos_df, votos_df) {
  votos_tratados_df <- votos_df %>%
    left_join(candidatos_df, by=c("nome_candidato")) %>%
    # Trata caso especial de Lauriete (PSC/ES) que possui 3 nomes diferentes
    mutate(cpf = ifelse(parlamentar.nome == "LAURIETE", "00974976733", cpf))
  
  return(votos_tratados_df)
}

#' @title Processa votações e informações dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param candidatos_datapath Datapath do csv com os dados dos candidatos
#' @param votacoes_datapath Datapath do csv com os dados das votações
#' @param candidatos_datapath Datapath do csv com os dados dos candidatos
#' @return Dataframe contendo o id da votação, o cpf e o voto dos deputados
#' @examples
#' processa_votos("./candidatos/output.csv", "./dados congresso/TabelaAuxVotacoes.csv")
processa_votos <- function(candidatos_datapath, votacoes_datapath, output_datapath) {
  candidatos_df <- read_csv(candidatos_datapath, col_types = "cicicnccc")
  votacoes_df <- read_csv(votacoes_datapath)
  
  cpf_nome_candidatos_df <- processa_candidatos(candidatos_df)
  votos_df <- processa_votacoes(votacoes_df)
  candidatos_e_votos_df <- candidatos_join_votos(cpf_nome_candidatos_df, votos_df)
  candidatos_faltantes_df <- candidatos_faltantes(candidatos_df, candidatos_e_votos_df)
  
  votos_completos <- 
    candidatos_e_votos_df %>% 
    select(-parlamentar.nome, -parlamentar.id,-nome_candidato) %>%
    bind_rows(candidatos_faltantes_df) %>% 
    complete(id_votacao, nesting(cpf)) %>%
    mutate(voto = enumera_votacoes(voto)) %>% 
    unique()
  
  return(votos_completos)
}

# sem_cpf %>%
#   select(parlamentar.nome, parlamentar.id, nomeCivil) %>%
#   unique() %>%
#   write.csv("cand_sem_cpf.csv", row.names = FALSE)
# 
# sem_cpf %>%
#   write.csv("cand_sem_cpf.csv", row.names = FALSE)

# Funções auxiliares:

# Verificar quem está sem o cpf
# sem_cpf <- votos_tratados %>% filter(is.na(cpf))

# Salvar como csv
# votos_completos %>%
#  write.csv("votacoes.csv", row.names=FALSE)

# Salvar como json
#votos_completos %>% 
#  dplyr::group_by(cpf, name, parlamentar.nome, parlamentar.id) %>% 
#  nest() %>% 
#  rename(projetos = data) %>% 
#  jsonlite::toJSON()
# devtools::install_github('analytics-ufcg/rcongresso')

library(rcongresso)
library(readr)
library(jsonlite)
library(tidyverse)
library(congressbr)

votacoes <- read_csv("~/Documentos/vozativa-monkey-ui/congresso/TabelaAuxVotacoes .csv")
candidatos_2018 <- read_csv("~/Documentos/vozativa-monkey-ui/congresso/candidatos_2018.csv")

ids_votacoes <- votacoes$id_votacao

deputados20142018_id <- fetch_deputado(idLegislatura = 55, itens = -1)$id

deputados20102014_id <- fetch_deputado(idLegislatura = 54, itens = -1)$id

info_pessoais_20102014 <- fetch_deputado(deputados20102014_id) %>% 
  select(id, nomeCivil)

info_pessoais_20142018 <- fetch_deputado(id_deputados) %>% 
  select(id, nomeCivil)

votos <- fetch_votos(votacoes$id_votacao) %>% 
  select(id_votacao, parlamentar.nome, parlamentar.id, voto) %>%
  left_join(votacoes, by="id_votacao")  %>% 
  left_join(info_pessoais_20142018, by= c("parlamentar.id" = "id")) %>%
  left_join(info_pessoais_20102014, by= c("parlamentar.id" = "id")) %>%
  mutate(nomeCivil = ifelse(is.na(nomeCivil.x), nomeCivil.y, nomeCivil.x)) %>%
  select(-nomeCivil.x, -nomeCivil.y)

# Falta pegar os dados dos candidatos de 2010~2014
votos_tratados <- candidatos_2018 %>%
  select(cpf, name) %>%
  right_join(votos, by=c("name"="nomeCivil"))

votos_tratados %>% 
  dplyr::group_by(cpf, name, parlamentar.nome, parlamentar.id) %>% 
  nest() %>% 
  rename(projetos = data) %>% 
  jsonlite::toJSON()

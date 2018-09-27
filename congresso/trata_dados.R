# devtools::install_github('analytics-ufcg/rcongresso')

library(rcongresso)
library(readr)
library(jsonlite)
library(tidyverse)

votacoes <- read_csv("~/Documentos/vozativa-monkey-ui/congresso/TabelaAuxVotacoes .csv")
candidatos_2018 <- read_csv("~/Documentos/vozativa-monkey-ui/congresso/candidatos_2018.csv")

ids_votacoes <- votacoes$id_votacao

deputados <- fetch_deputado(itens = 520) %>% unique() 

id_deputados <- deputados$id

info_pessoais_dep <- fetch_deputado(id_deputados)

votos <- fetch_votos(votacoes$id_votacao) %>% 
  select(id_votacao, parlamentar.nome, voto) %>%
  left_join(votacoes, by="id_votacao")  %>% 
  left_join(info_pessoais_dep, by= c("parlamentar.nome" = "ultimoStatus.nomeEleitoral")) 

votos <- votos %>% select(id_votacao, parlamentar.nome, voto, cpf.y, nomeCivil, name, ultimoStatus.nomeEleitoral) 
votosu <- na.omit(votos)
votos %>% 
  dplyr::group_by(parlamentar.nome) %>% 
  nest() %>% 
  rename(projetos = data) %>% jsonlite::toJSON()

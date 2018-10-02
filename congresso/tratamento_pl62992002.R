#!/usr/bin/env Rscript

# devtools::install_github('analytics-ufcg/rcongresso')
# install.packages("tm", repos="http://R-Forge.R-project.org")

# Bibliotecas
library(tidyverse)
library(rcongresso)
library(tm)
library(stringr)

# Diretório de arquivos
PL6299_2002_DIRETORIO <- "./dados_congresso/pl62992002.csv"
INFO_CANDIDATOS <- "./dados_congresso/candidatos_2010_14_18.csv"

# Remove stopwords dos nomes dos candidatos/deputados
stopwords_regex <- paste(toupper(stopwords('pt')), collapse = '\\b|\\b')
stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')

# Import dos dados
pl6299_2002 <- read_csv(PL6299_2002_DIRETORIO)
candidatos_2010a2018 <- read_csv(INFO_CANDIDATOS)

# Tratamento de string - Remove acentuação, apóstrofes, deixa todos maiúsculos e remove
# stopwords
info_util_candidatos <- candidatos_2010a2018 %>%
  select(name, cpf) %>% 
  mutate(name = toupper(iconv(name, to="ASCII//TRANSLIT"))) %>%
  unique() %>%
  mutate(name = str_replace_all(name, stopwords_regex, "")) %>%
  mutate(name = str_replace_all(name, "  "," ")) %>%
  mutate(name = str_replace_all(name, "'","  "))

pl6299_2002 <- pl6299_2002 %>%
  mutate(nome = toupper(iconv(nome, to="ASCII//TRANSLIT"))) %>%
  mutate(nome = str_replace_all(nome, stopwords_regex, "")) %>%
  mutate(nome = str_replace_all(nome, "  "," ")) %>%
  mutate(nome = str_replace_all(nome, "'","  "))

deputados20142018_id <- fetch_deputado(idLegislatura = 55, itens = -1)$id

info_pessoais_20142018 <- fetch_deputado(deputados20142018_id) %>% 
  select(id, nomeCivil, ultimoStatus.nome) %>%
  mutate(ultimoStatus.nome = toupper(iconv(ultimoStatus.nome, to="ASCII//TRANSLIT"))) %>%
  mutate(ultimoStatus.nome = str_replace_all(ultimoStatus.nome, stopwords_regex, "")) %>%
  mutate(ultimoStatus.nome = str_replace_all(ultimoStatus.nome, "  "," ")) %>%
  mutate(ultimoStatus.nome = str_replace_all(ultimoStatus.nome, "'","  "))

pl6299_tratada <- pl6299_2002 %>%
  left_join(info_pessoais_20142018, by=c("nome"="ultimoStatus.nome")) %>%
  mutate(nomeCivil = toupper(iconv(nomeCivil, to="ASCII//TRANSLIT"))) %>%
  mutate(nomeCivil = str_replace_all(nomeCivil, stopwords_regex, "")) %>%
  mutate(nomeCivil = str_replace_all(nomeCivil, "  "," ")) %>%
  mutate(nomeCivil = str_replace_all(nomeCivil, "'","  ")) %>%
  left_join(info_util_candidatos, by=c("nomeCivil"="name"))

pl6299_tratada %>%
  write.csv("pl6299_tratada.csv", row.names = FALSE)

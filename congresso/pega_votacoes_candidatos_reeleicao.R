#!/usr/bin/env Rscript

# devtools::install_github('analytics-ufcg/rcongresso')
# install.packages("tm", repos="http://R-Forge.R-project.org")

# Bibliotecas
library(tidyverse)
library(rcongresso)
library(tm)
library(stringr)

# Funções
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

# Diretório de arquivos
INFO_VOTACOES <- "./dados congresso/TabelaAuxVotacoes.csv"
INFO_CANDIDATOS <- "./candidatos/output.csv"
PL6299_2002_DIRETORIO <- "./dados congresso/pl6299_tratada.csv"

# Remove stopwords dos nomes dos candidatos/deputados
stopwords_regex <- paste(toupper(stopwords('pt')), collapse = '\\b|\\b')
stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')

# Import dos dados
votacoes <- read_csv(INFO_VOTACOES)
candidatos_2010a2018 <- read.csv(INFO_CANDIDATOS)
pl6299_2002 <- read_csv(PL6299_2002_DIRETORIO) %>%
  select(id_votacao, voto, cpf_candidato)

# Tratamento de string - Remove acentuação, apóstrofes, deixa todos maiúsculos e remove
# stopwords
info_util_candidatos <- candidatos_2010a2018 %>%
  select(nome_candidato, cpf_candidato) %>% 
  mutate(nome_candidato = toupper(iconv(nome_candidato, to="ASCII//TRANSLIT"))) %>%
  unique() %>%
  mutate(nome_candidato = str_replace_all(nome_candidato, stopwords_regex, "")) %>%
  mutate(nome_candidato = str_replace_all(nome_candidato, "  "," ")) %>%
  mutate(nome_candidato = str_replace_all(nome_candidato, "'","  "))

ids_votacoes <- votacoes$id_votacao
deputados20142018_id <- fetch_deputado(idLegislatura = 55, itens = -1)$id
deputados20102014_id <- fetch_deputado(idLegislatura = 54, itens = -1)$id

info_pessoais_20102014 <- fetch_deputado(deputados20102014_id) %>% 
  select(id, nomeCivil)

info_pessoais_20142018 <- fetch_deputado(deputados20142018_id) %>% 
  select(id, nomeCivil)

ids <- ids_votacoes[1:15]
ids2 <- ids_votacoes[16:34]

  votos <- fetch_votos(ids) %>% dplyr::bind_rows(fetch_votos(ids2)) %>%
    select(id_votacao, parlamentar.nome, parlamentar.id, voto) %>% 
    left_join(info_pessoais_20142018, by= c("parlamentar.id" = "id")) %>%
    left_join(info_pessoais_20102014, by= c("parlamentar.id" = "id")) %>%
    mutate(nomeCivil = ifelse(is.na(nomeCivil.x), nomeCivil.y, nomeCivil.x)) %>%
    mutate(nomeCivil = toupper(iconv(nomeCivil, to="ASCII//TRANSLIT"))) %>%
    mutate(nomeCivil = str_replace_all(nomeCivil, stopwords_regex, "")) %>%
    mutate(nomeCivil = str_replace_all(nomeCivil, "  "," ")) %>%
    mutate(nomeCivil = str_replace_all(nomeCivil, "'","  ")) %>%
    select(-nomeCivil.x, -nomeCivil.y)

votos_tratados <- votos %>%
  left_join(info_util_candidatos, by=c("nomeCivil"="nome_candidato")) %>%
  # Trata caso especial de Lauriete (PSC/ES) que possui 3 nomes diferentes
  mutate(cpf_candidato = ifelse(parlamentar.nome == "LAURIETE", "00974976733", cpf_candidato))

# CPFs dos candidatos a reeleição na plataforma voz ativa
cpfs_voz <- candidatos_2010a2018 %>%
  mutate(situacao_reeleicao = if_else(situacao_reeleicao == 'S', 1, 0)) %>% 
  filter(situacao_reeleicao == 1) %>% select(cpf_candidato) %>% unique()

# CPFs dos deputados que votaram na câmara 
cpf_completos <- votos_tratados %>% select(cpf_candidato) %>%  unique()

# CPFs dos deputados que estão no voz ativa e não estão na câmara
faltantes <- cpfs_voz[!(cpfs_voz$cpf_candidato %in% cpf_completos$cpf_candidato),] %>% 
  as.character()
faltantes <-
  faltantes %>% 
  as.data.frame() %>% 
  mutate(id_votacao = 4968, voto = "-") %>% 
  rename(cpf_candidato = ".")


# Fazer com que cada deputado tenha todas as votações e tratar os casos como ele não votou
votos_completos$cpf_candidato = as.character(votos_completos$cpf_candidato)
pl6299_2002$cpf_candidato = as.character(pl6299_2002$cpf_candidato)

votos_completos <- 
  votos_tratados %>% 
  select(-parlamentar.nome, -parlamentar.id,-nomeCivil) %>%
  bind_rows(pl6299_2002) %>%
  bind_rows(faltantes) %>% 
  complete(id_votacao, nesting(cpf_candidato)) %>%
  mutate(voto = enumera_votacoes(voto)) %>% 
  unique()


votos_completos %>%
  write.csv("./dados congresso/votacoes.csv", row.names = FALSE)

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

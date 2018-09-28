# devtools::install_github('analytics-ufcg/rcongresso')
# install.packages("tm", repos="http://R-Forge.R-project.org")

library(tidyverse)
library(rcongresso)
library(tm)
library(stringr)

enumera_votacoes <- Vectorize(function(voto) {
  voto <- as.character(voto)
  switch (voto,
          "Não" = -1,
          "Sim" = 1,
          "NA" = 0,
          "null" = 0,
          "Obstrução" = 0,
          "Abstenção" = 0,
          "Art. 17" = 0
  )
})

# Remove stopwords dos nomes dos candidatos/deputados
stopwords_regex <- paste(toupper(stopwords('pt')), collapse = '\\b|\\b')
stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')

#stringr::str_replace_all(nomes_sem_cpf, stopwords_regex, '') %>%
#  str_replace("  "," ")

votacoes <<- read_csv("~/Documentos/vozativa-monkey-ui/congresso/TabelaAuxVotacoes .csv")
candidatos_2010a2018 <<- read_csv("~/Documentos/vozativa-monkey-ui/congresso/candidatos_2010_14_18.csv")

info_util_candidatos <- candidatos_2010a2018 %>%
  select(name, cpf) %>% 
  mutate(name = toupper(iconv(name, to="ASCII//TRANSLIT"))) %>%
  unique() %>%
  mutate(name = str_replace_all(name, stopwords_regex, "")) %>%
  mutate(name = str_replace_all(name, "  "," "))

ids_votacoes <- votacoes$id_votacao

deputados20142018_id <- fetch_deputado(idLegislatura = 55, itens = -1)$id

deputados20102014_id <- fetch_deputado(idLegislatura = 54, itens = -1)$id

info_pessoais_20102014 <- fetch_deputado(deputados20102014_id) %>% 
  select(id, nomeCivil)

info_pessoais_20142018 <- fetch_deputado(deputados20142018_id) %>% 
  select(id, nomeCivil)

votos <- fetch_votos(votacoes$id_votacao) %>% 
  select(id_votacao, parlamentar.nome, parlamentar.id, voto) %>% 
  left_join(info_pessoais_20142018, by= c("parlamentar.id" = "id")) %>%
  left_join(info_pessoais_20102014, by= c("parlamentar.id" = "id")) %>%
  mutate(nomeCivil = ifelse(is.na(nomeCivil.x), nomeCivil.y, nomeCivil.x)) %>%
  mutate(nomeCivil = toupper(iconv(nomeCivil, to="ASCII//TRANSLIT"))) %>%
  mutate(nomeCivil = str_replace_all(nomeCivil, stopwords_regex, "")) %>%
  mutate(nomeCivil = str_replace_all(nomeCivil, "  "," ")) %>%
  select(-nomeCivil.x, -nomeCivil.y)

votos_tratados <- votos %>%
  left_join(info_util_candidatos, by=c("nomeCivil"="name"))

# Fazer com que cada deputado tenha todas as votações e tratar os casos como ele não votou
votos_completos <- votos_tratados %>% select(-parlamentar.nome, -parlamentar.id,-nomeCivil) %>%
  complete(id_votacao, nesting(cpf, voto)) %>%
  mutate(voto = enumera_votacoes(voto))

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

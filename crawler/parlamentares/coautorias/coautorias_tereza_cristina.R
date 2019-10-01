library(tidyverse)
library(here)

source(here("crawler/proposicoes/fetcher_propoposicoes_camara.R"))
source(here("crawler/parlamentares/coautorias/fetcher_authors.R"))

parlamentares <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(.default = "c")) %>% 
  filter(casa == "camara", em_exercicio == 1) %>% 
  select(id, nome_eleitoral, sg_partido, uf)

id_parlamentar <- 178901

proposicoes <- fetch_proposicoes_por_autor(178901)

relacionadas <- fetch_all_relacionadas(proposicoes$id)

autores <- fetch_all_autores(relacionadas) %>%
  rename(id_req = id, id = id_deputado) %>%
  distinct() %>%
  group_by(id_req) %>%
  mutate(peso_arestas = 1 / n()) %>% 
  ungroup()

coautorias <- get_coautorias(parlamentares, autores)

coautorias <- coautorias %>% 
  filter(id.x == id_parlamentar | id.y == id_parlamentar) %>% 
  mutate(peso_arestas = round(peso_arestas, 2),
         nome_eleitoral.x = paste0(nome_eleitoral.x, " - ", sg_partido.x, "/", uf.x),
         nome_eleitoral.y = paste0(nome_eleitoral.y, " - ", sg_partido.y, "/", uf.y)) %>% 
  select(-c(sg_partido.x, sg_partido.y, uf.x, uf.y))

write_csv(coautorias, here("crawler/raw_data/coautorias_tereza_cristina.csv"))

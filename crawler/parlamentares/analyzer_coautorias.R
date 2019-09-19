#' @title Gera dataframe de coautorias
#' @description A partir de um conjunto de parlamentares e autores de proposições,
#' retorna um dataframe de coautorias, onde cada linha representa um par de deputados
#' que coautoraram em proposições
#' @param parlamentares_datapath Dataframe dos parlamentares
#' @param autores_coautorias_datapath Dataframe dos autores de proposições
#' @return Dataframe contendo informações sobre as coautorias
process_coautorias <- function(
  autores_coautorias_datapath = here::here("crawler/raw_data/deputados_autores_proposicoes_2019.csv"),
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/coautorias/fetcher_authors.R"))
  
  autores <- read_csv(autores_coautorias_datapath, col_types = cols(id = "c"))
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c")) %>% 
    select(id, nome_eleitoral, sg_partido, uf)
  
  coautorias <- get_coautorias(parlamentares, autores)
  
  return(coautorias)
}

#' @title Filtra os 100 deputados mais ativistas ambientais
#' @description A partir de um conjunto de dados sobre os parlamentares, filtra os que possuem maior índice de 
#' ativismo ambiental.
#' @param url_ambientalistas URL para a planilha com as informações de ativismo ambiental
#' @return Dataframe com os 100 deputados mais ativistas ambientais
filter_deputados_ambientalistas <- function(
  url_ambientalistas = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRtD72wntBGbWewLB7SJjF4GC_WPBWfAVGRazycgU1H-wd5Yn6FBQlV_o4n26x5W6VNdmrb0Tnfio0n/pub?gid=1759696780&single=true&output=csv")  {
  
  library(tidyverse)
  
  ambientalistas <- read_csv(url_ambientalistas, col_types = cols(`Identificação Deputado` = "c")) %>% 
    arrange(desc(`Índice de Ativismo Ambiental`)) %>% 
    head(100) %>% 
    select(id_coautor_ambientalista = `Identificação Deputado`,
           nome_coautor_ambientalista = `Deputado`)
  
  return(ambientalistas)
  
}

#' @title Filtra os deputados que coautoram com deputados ambientalistas
#' @description A partir de um conjunto de dados sobre os deputados que possuem maior índice de 
#' ativismo ambiental e de um conjunto de coautorias, retorna os que coautoraram com ambientalistas.
#' @param coautorias Dataframe de coautorias
#' @param ambientalistas Dataframe dos deputados mais ambientalistas
#' @return Dataframe com os 100 deputados mais ativistas ambientais
coautorias_ambientalistas <- function(
  coautorias = process_coautorias(),
  ambientalistas = filter_deputados_ambientalistas()) {
  
  library(tidyverse)
  
  coautores_ambientalistas <- coautorias %>% 
    filter(!id.x %in% ambientalistas$id_coautor_ambientalista,
           id.y %in% ambientalistas$id_coautor_ambientalista)
  
  coautores_ambientalistas <- coautores_ambientalistas %>%
    group_by(id.x) %>%
    mutate(coautores_ambientalistas =
             paste(nome_eleitoral.y %>%
                     unique(),
                   collapse = ", ")) %>%
    select (-c(id.y, nome_eleitoral.y, sg_partido.y, uf.y)) %>%
    distinct() %>%
    mutate(total_peso_relacao_ambientalistas = sum(peso_arestas)) %>%
    select(-c(id_req, peso_arestas)) %>%
    distinct()
  
  return(coautores_ambientalistas)
  
}

#' @title Retorna os nodes e as edges da rede de coautorias para um
#' conjunto de anos e tema selecionado
#' @description Retorna os nodes e as edges da rede de coautorias para um
#' conjunto de anos e tema selecionado
#' @param anos Anos de interesse
#' @param tema Tema selecionado
#' @param parlamentares_datapath Caminho para o datapath de parlamentares
#' @return Retorna os nodes e as edges da rede de coautorias para um
#' conjunto de anos e tema selecionado
generate_coautorias <-
  function(anos = c(2019, 2020),
           tema = "Meio Ambiente",
           parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
    library(tidyverse)
    
    source(here::here("crawler/coautorias/proposicoes/fetcher_proposicoes.R"))
    source(here::here("crawler/coautorias/proposicoes/fetcher_relacionadas.R"))
    source(here::here("crawler/coautorias/autores/fetcher_autores.R"))
    source(here::here("crawler/coautorias/coautorias/process_coautorias.R"))
    source(here::here("crawler/coautorias/grafo/process_grafo.R"))
    
    parlamentares <- read_csv(parlamentares_datapath, 
                              col_types = cols(.default = "c"))
    
    proposicoes_do_tema <-
      fetch_all_propositions_by_ano_e_tema(anos, tema)
    
    proposicoes_e_relacionadas <-
      fetch_all_relacionadas(proposicoes_do_tema %>% pull(id))
    
    autores <- fetch_all_autores(proposicoes_e_relacionadas, parlamentares)
    
    coautorias <- get_coautorias(parlamentares, autores)
    
    nodes_edges <- generate_nodes_and_edges(autores, parlamentares, coautorias)
    
    return(nodes_edges)
    
  }
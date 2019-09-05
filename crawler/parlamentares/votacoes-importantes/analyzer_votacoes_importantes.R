#' @title Processa votações importantes dada uma URL com a lista de votações específicas
#' @description A partir da informação de votações específicas recupera os votos dos deputados
#' @param URL URL para lista de votações importantes
#' @return Dataframe contendo informações de deputados e seus votos em votações importantes
#' @examples
#' process_votacoes_importantes()
process_votacoes_importantes <- function(
  URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTI6--KJSsbQEtFSHBC6cWoc_jcvGx9oKgnPHedOIDsPMH43UrnSPSd-qauxIV0HpcFA3s9C2D3ubok/pub?gid=0&single=true&output=csv") {
  
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  
  votacoes_importantes <- read_csv(URL, col_types = cols(.default = "c")) %>% 
    filter(status == "ativa")
  
  votos_raw <- purrr::pmap_dfr(list(votacoes_importantes$id_proposicao, 
                                votacoes_importantes$titulo_proposicao,
                                votacoes_importantes$cod_sessao, 
                                votacoes_importantes$resumo,
                                votacoes_importantes$obj_votacao), 
                           ~ fetch_votos_por_votacao_camara(..1, ..2, ..3, ..4, ..5))
    
  deputados_votos <- votos_raw %>% 
    mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":"))) %>% 
    select(id_deputado, id_votacao, id_proposicao, partido, voto) %>% 
    
    left_join(votacoes_importantes %>% select(id_votacao, titulo_proposicao, posicao_ma), 
              by = "id_votacao") %>% 
    mutate(titulo_proposicao = paste0(titulo_proposicao, " (", posicao_ma, ")")) %>% 
    
    select(id_deputado, titulo_proposicao, voto) %>% 
    spread(titulo_proposicao, voto)
  
  return(deputados_votos)
}

#' @title Filtra dados de votações importantes de deputados para considerar apenas os atualmente em exercício
#' @description Usando a lista de deputados atualmente em exercício filtra as informações de votos em votações
#' mais importantes
#' @return Dataframe contendo informações de deputados em exercício e suas votações importantes
#' @examples
#' filter_deputados_atuais_votacoes()
filter_deputados_atuais_votacoes <- function() {
  library(tidyverse)
  library(here)
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  deputados_votos <- process_votacoes_importantes() %>%
    mutate(id_deputado = as.character(id_deputado))
  
  deputados_votos_reeleitos <- deputados %>%
    inner_join(deputados_votos, by = c("id" = "id_deputado")) %>%
    select(-c(casa, nome_civil, genero, situacao, condicao_eleitoral, ultima_legislatura, em_exercicio))
    
  return(deputados_votos_reeleitos)
}

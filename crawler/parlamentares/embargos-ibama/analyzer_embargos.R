#' @title Processa dados de embargos do ibama
#' @description Realiza a leitura dos dados do ibama e formata o CPF
#' @param embargos_datapath Caminho para dados de embargos do ibama
#' @return Dataframe contendo informações de embargos
#' @examples
#' embargos <- process_embargos_ibama()
process_deputados_embargos <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/embargos-ibama/process_embargos.R"))

  embargos <- process_embargos_ibama()  
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(em_exercicio == 1, casa == "camara")
  
  deputados_embargos <- deputados %>% 
    inner_join(embargos, by = c("cpf" = "cpf_cnpj"))
  
  return(deputados_embargos)
}

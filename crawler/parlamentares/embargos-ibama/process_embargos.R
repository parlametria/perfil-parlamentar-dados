#' @title Processa dados de embargos do ibama
#' @description Realiza a leitura dos dados do ibama e formata o CPF
#' @param embargos_datapath Caminho para dados de embargos do ibama
#' @return Dataframe contendo informações de embargos
#' @examples
#' embargos <- process_embargos_ibama()
process_embargos_ibama <- function(
  embargos_datapath = here::here("crawler/parlamentares/embargos-ibama/areas_embargadas_ibama.csv")) {
  library(tidyverse)
  library(here)
  
  embargos <- read_csv(embargos_datapath)
  
  embargos_alt <- embargos %>% 
    mutate(cpf_cnpj = str_replace_all(`CPF ou CNPJ`, "([-./])", "")) %>% 
    select(cpf_cnpj, localizacao = `Localização do Imóvel`, uf = `UF Embargo`, 
           municipio_embargo = `Município Embargo`, municipio = Município,
           endereco = Endereço, julgamento = Julgamento, infracao = Infração,
           data_insercao_lista = `Data de Inserção na Lista`)
 
  return(embargos_alt) 
}

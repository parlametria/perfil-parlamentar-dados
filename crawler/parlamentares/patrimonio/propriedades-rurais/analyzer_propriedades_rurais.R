#' @title Processa dados de propriedades rurais para os deputados atualmente em exerício na Câmara dos Deputados
#' @description A partir dos dados de bens rurais declarados ao TSE cruza com a lista de deputados em exercício
#' @return Dataframe contendo deputados em exerício que possuem propriedades rurais
#' @examples
#' deputados_propriedades_rurais <- process_deputados_propriedades_rurais()
process_deputados_propriedades_rurais <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/patrimonio/propriedades-rurais/process_propriedades_rurais.R"))
  
  bens_rurais <- process_propriedades_rurais() %>% 
    mutate(link = paste0("http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2018/2022802018/", 
                         SG_UE, 
                         "/",
                         SQ_CANDIDATO,
                         "/bens")) %>% 
    group_by(NR_CPF_CANDIDATO) %>% 
    summarise(
      link = first(link),
      n_propriedades = n(),
      total = sum(VR_BEM_CANDIDATO)) %>% 
    ungroup()
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  deputados_bens_rurais <- deputados %>% 
    left_join(bens_rurais, by = c("cpf" = "NR_CPF_CANDIDATO")) %>% 
    filter(!is.na(n_propriedades)) %>% 
    mutate(total = round(total, 2)) %>% 
    select(cpf, id_camara = id, nome_eleitoral, uf, sg_partido, n_propriedades, total_declarado = total, link)
  
  return(deputados_bens_rurais)
}

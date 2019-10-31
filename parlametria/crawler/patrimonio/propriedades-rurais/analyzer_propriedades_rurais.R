#' @title Processa dados de propriedades rurais para os parlamentares atualmente em exercício
#' @description A partir dos dados de bens rurais declarados ao TSE cruza com a lista de parlamentares em exercício passada como 
#' parâmetro. 
#' @param casa_origem Casa de origem para os dados de parlamentares
#' @return Dataframe contendo parlamentares em exerício que possuem propriedades rurais
#' @examples
#' deputados <- parlamentares %>% filter(casa == "camara", em_exercicio == 1)
#' deputados_propriedades_rurais <- filtra_propriedades_rurais_parlamentares(deputados)
filtra_propriedades_rurais_parlamentares <- function(
  casa_origem = "camara"
) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/patrimonio/propriedades-rurais/process_propriedades_rurais.R"))
  
  bens_rurais <- process_propriedades_rurais() %>% 
    mutate(link = paste0("http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2018/2022802018/", 
                         SG_UE, 
                         "/",
                         SQ_CANDIDATO,
                         "/bens")) %>% 
    group_by(NR_CPF_CANDIDATO) %>% 
    summarise(
      nome_deputado = first(NM_CANDIDATO),
      link = first(link),
      descricao = paste0(DS_BEM_CANDIDATO, collapse = "; "),
      n_propriedades = n(),
      total = sum(VR_BEM_CANDIDATO)) %>% 
    ungroup()
  
  parlamentares <- readr::read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == casa_origem, em_exercicio == 1)
  
  if (casa_origem == "camara") {
    ## JOIN por cpf
    parlamentares_bens_rurais <- parlamentares %>% 
      left_join(bens_rurais, by = c("cpf" = "NR_CPF_CANDIDATO"))    
  } else if (casa_origem == "senado") {
    source(here("crawler/utils/utils.R"))
    
    ## JOIN por nome completo padronizado
    parlamentares_bens_rurais <- parlamentares %>% 
      mutate(nome_padronizado = padroniza_nome(nome_civil)) %>% 
      left_join(bens_rurais %>% 
                  mutate(nome_padronizado = padroniza_nome(nome_deputado)), 
                by = c("nome_padronizado")) %>% 
      mutate(cpf = NR_CPF_CANDIDATO)
  } else {
    stop("O parâmetro casa_origem deve ser 'camara' ou 'senado'")
  }

  parlamentares_bens_rurais_alt <- parlamentares_bens_rurais %>% 
    filter(!is.na(n_propriedades)) %>% 
    mutate(total = round(total, 2)) %>% 
    select(cpf, id_parlamentar = id, casa, nome_eleitoral, uf, sg_partido, n_propriedades, total_declarado = total, 
           descricao, link)
  
  return(parlamentares_bens_rurais_alt)
}

#' @title Processa dados de propriedades rurais para os deputados e senadores atualmente em exercício na Câmara dos Deputados
#' @description A partir dos dados de bens rurais declarados ao TSE cruza com a lista de deputados e senadores em exercício
#' @return Dataframe contendo deputados e senadores em exerício que possuem propriedades rurais
#' @examples
#' deputados_propriedades_rurais <- process_deputados_propriedades_rurais()
process_parlamentares_propriedades_rurais <- function() {
  library(tidyverse)
  library(here)
  
  deputados_propriedades_rurais <- filtra_propriedades_rurais_parlamentares("camara")
  
  senadores_propriedades_rurais <- filtra_propriedades_rurais_parlamentares("senado")
  
  parlamentares_propriedades_rurais <- deputados_propriedades_rurais %>% 
    rbind(senadores_propriedades_rurais)
  
  return(parlamentares_propriedades_rurais)
}


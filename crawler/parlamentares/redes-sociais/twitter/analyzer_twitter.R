#' @title Recupera username dos deputados no twitter e cruza com deputados atualmente em exercício
#' @description A partir da URL do csv com dados de redes sociais de deputados cruza com a lista de deputados atualmente em exercício
#' @return Dataframe com deputados em exercício e seus respectivos usernames no twitter
#' @examples
#' deputados_username_twitter <- fetch_deputados_twitter_name()
fetch_deputados_twitter_name <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/parlamentares/redes-sociais/twitter/constants.R"))
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  redes_sociais_deputados <- read_csv(.URL_REDES_SOCIAIS_PARLAMENTARES,
                                      col_types = cols(id_parlamentar = "c")) %>% 
    filter(casa == "câmara") %>% 
    select(id = id_parlamentar, twitter)
  
  deputados_twitter <- deputados %>% 
    select(id, cpf, nome_eleitoral, sg_partido, uf) %>% 
    left_join(redes_sociais_deputados, by = "id")
  
  return(deputados_twitter)
}

#' @title Recupera os dados dos últimos tweets para os deputados atualmente em exerício
#' @description Pela API do twitter recupera os últimos tweets de deputados em execício na Câmara
#' @return Dataframe com tweets dos deputados
#' @examples
#' tweets_deputados <- process_tweets_deputados()
process_tweets_deputados <- function() {
}
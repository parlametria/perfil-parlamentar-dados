#' @title Cruza os dados de parlamentares com informações de redes sociais 
#' @description Realiza o cruzamento dos dados de redes sociais para os parlametares passados como entrada
#' @param parlamentares Dados dos parlamentares para obtenção das informações de rede social
#' @param redes_sociais DataFrame com as redes sociais (feito pela equipe do Serenata de Amor)
#' @return Dataframe informações do parlamentar e de suas redes sociais
#' @examples
#' deputados_redes_sociais <- parlamentar_rede_social_merge()
parlamentar_rede_social_merge <- function(parlamentares, redes_sociais) {
  
  parlamentares_rede_social <- parlamentares %>% 
    dplyr::left_join(redes_sociais %>% 
                       dplyr::select(congressperson_id, twitter_profile, facebook_page), 
                     by = c("id" = "congressperson_id")) %>% 
    arrange(nome_civil) %>% 
    
    mutate(twitter_profile = ifelse(is.na(twitter_profile), "-", twitter_profile)) %>% 
    mutate(facebook_page = ifelse(is.na(facebook_page), "-", facebook_page)) %>%
    mutate(nome_civil = toupper(nome_civil))
  
  return(parlamentares_rede_social)
}


#' @title Processa dados das redes sociais dos deputados federais da atual legislatura
#' @description Realiza o cruzamento dos dados de redes sociais para os deputados atuais da atual legislatura 
#' @return Dataframe informações do deputado e de suas redes sociais
#' @examples
#' deputados_redes_sociais <- process_rede_social_deputados()
process_rede_social_deputados <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))
  
  redes_sociais_leg55 <- readr::read_csv(here::here("crawler/raw_data/2017-06-11-congresspeople-social-accounts.csv"))
  
  deputados_atuais <- fetch_deputados(legislatura = 56)
  
  deputados_atuais_rede_social <- parlamentar_rede_social_merge(deputados_atuais, redes_sociais_leg55) %>% 
    mutate(casa = "câmara") %>% 
    select(id_parlamentar = id, casa, nome_civil, twitter = twitter_profile, facebook = facebook_page)
    
  return(deputados_atuais_rede_social)
  
}

#' @title Processa dados das redes sociais dos senadores atuais
#' @description Realiza o cruzamento dos dados de redes sociais para os senadores atuais
#' @return Dataframe informações do senador e de suas redes sociais
#' @examples
#' senadores_redes_sociais <- process_rede_social_senadores()
process_rede_social_senadores <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/fetcher_parlamentar.R"))
  
  redes_sociais_leg55 <- readr::read_csv(here::here("crawler/raw_data/2017-06-11-congresspeople-social-accounts.csv"))

  senadores_atuais <- fetch_senadores_atuais() %>% 
    mutate(id = as.numeric(id))
  
  senadores_atuais_rede_social <- parlamentar_rede_social_merge(senadores_atuais, redes_sociais_leg55) %>% 
    mutate(casa = "senado") %>% 
    select(id_parlamentar = id, casa, nome_civil, twitter = twitter_profile, facebook = facebook_page)
  
  return(senadores_atuais_rede_social)
  
}

#' @title Processa dados das redes sociais dos parlamentares atuais
#' @description Realiza o cruzamento dos dados de redes sociais para os parlamentares atuais
#' @return Dataframe informações do parlamentar e de suas redes sociais
#' @examples
#' parlamentares_redes_sociais <- process_rede_social_parlamentares()
process_rede_social_parlamentares <- function() {
  library(tidyverse)
  library(here)
  
  deputados <- process_rede_social_deputados()
  senadores <- process_rede_social_senadores()
  
  parlamentares <- deputados %>% rbind(senadores)
  
  return(parlamentares)
}

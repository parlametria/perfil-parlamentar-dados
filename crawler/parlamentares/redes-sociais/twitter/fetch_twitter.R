#' @title Cria token para a API do Twitter
#' @description Cria token com credenciais para a API do Twitter
#' @examples
#' create_token_twitter_api()
create_token_twitter_api <- function() {
  library(here)
  library(config)
  library(rtweet)
  
  keys <- config::get(file = here("crawler/parlamentares/redes-sociais/twitter/config.yml"))
  
  create_token(
    app = "16299739",
    consumer_key = keys$consumer_key,
    consumer_secret = keys$consumer_secret,
    access_token = keys$access_token,
    access_secret = keys$access_secret
    )
}

#' @title Recupera tweets a partir de um username
#' @description Recupera últimos n tweets da timeline de um usuário
#' @param username Username no twitter
#' @param n Número de tweets para recuperar da timeline
#' @param timeout Tempo de espera (em segundos) para a requisição acontecer
#' @return Dataframe com informações sobre os tweets de um usuário
#' @examples
#' username_tweets <- fetch_tweets_from_username("vanicosta10", n = 400)
fetch_tweets_from_username <- function(username, n = 1000, timeout = 0) {
  library(tidyverse)
  library(here)
  library(rtweet)
  
  print(paste0("Recuperando tweets de ", username))
  
  Sys.sleep(timeout)
  
  ## Adiciona credenciais do twitter
  # create_token_twitter_api()
  
  tweets <- get_timelines(username, n)
  
  return(tweets)
}

#' @title Recupera atividade de tweets de uma lista de parlamentares
#' @description Recupera atividade de tweets de uma lista de parlamentares presentes na URL https://datahub.io/jeffersonrpn/redes-sociais-parlamentares-brasil/r/redes-sociais-parlamentares.csv 
#' @return Dataframe com informações sobre os tweets de uma lista de parlamentares
#' @examples
#' tweets <- fetch_tweets_from_parlamentares()
fetch_tweets_from_parlamentares <- function() {
  library(tidyverse)
  library(jsonlite)
  library(lubridate)
  library(here)
  source(here("crawler/parlamentares/redes-sociais/twitter/constants.R"))
  
  data <- read_csv(.URL_REDES_SOCIAIS_PARLAMENTARES_DATAHUB)
  
  data_filtrada <- data %>% filter(!is.na(twitter) & twitter != "" & casa == 'câmara') %>% 
    slice(1:150) ## aplica filtro para reduzir número de requisições para o teste. Remova caso queira capturar para todos
  
  twitter_data <- purrr::map_df(.x = data_filtrada$twitter, ~ fetch_tweets_from_username(.x))
  
  data_hoje <- lubridate::as_date(today())
  
  atividade <- twitter_data %>% 
    mutate(created_at_date = as_date(created_at)) %>% 
    filter(created_at_date >= data_hoje - 30) %>% 
    group_by(user_id, screen_name) %>% 
    summarise(n = n(), data_minima = data_hoje - 30, data_ultimo_tweet = max(created_at_date))

  return(atividade)
}

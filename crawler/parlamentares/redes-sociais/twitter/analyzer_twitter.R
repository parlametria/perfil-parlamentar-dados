#' @title Recupera username dos deputados no twitter e cruza com deputados atualmente em exercício
#' @description A partir da URL do csv com dados de redes sociais de deputados cruza com a lista de deputados atualmente em exercício
#' @return Dataframe com deputados em exercício e seus respectivos usernames no twitter
#' @examples
#' deputados_username_twitter <- fetch_deputados_twitter_name()
fetch_deputados_twitter_name <- function() {
  library(tidyverse)
  source(here::here("crawler/parlamentares/redes-sociais/twitter/constants.R"))
  
  deputados <- read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  redes_sociais_deputados <- read_csv(.URL_REDES_SOCIAIS_PARLAMENTARES,
                                      col_types = cols(id_parlamentar = "c")) %>% 
    filter(casa == "câmara") %>% 
    select(id = id_parlamentar, twitter)
  
  deputados_twitter <- deputados %>% 
    select(id, cpf, nome_eleitoral, sg_partido, uf) %>% 
    left_join(redes_sociais_deputados, by = "id") %>% 
    mutate(twitter = str_replace_all(twitter, "[^[:alnum:]]", ""))
  
  return(deputados_twitter)
}

#' @title Recupera os dados dos últimos tweets para os deputados atualmente em exerício
#' @description Pela API do twitter recupera os últimos tweets de deputados em execício na Câmara
#' @return Dataframe com tweets dos deputados
#' @examples
#' tweets_deputados <- process_tweets_deputados()
process_tweets_deputados <- function() {
  library(tidyverse)
  source(here::here("crawler/parlamentares/redes-sociais/twitter/fetch_twitter.R"))
  
  deputados <- fetch_deputados_twitter_name() %>% 
    filter(!is.na(twitter))
  
  deputados <- deputados_301_400 %>% rbind(deputados_401_468)
  
  tweets_deputados <- purrr::map_df(.x = deputados$twitter, ~ fetch_tweets_from_username(.x, n = 1000, timeout = 70)) %>% 
    mutate(screen_name = tolower(screen_name)) %>% 
    select(user_id, screen_name, created_at, text, favorite_count, retweet_count, media_url, media_expanded_url, mentions_screen_name)
  
  deputados_merge <- deputados %>% 
    mutate(twitter = tolower(twitter)) %>% 
    full_join(tweets_deputados, by = c("twitter" = "screen_name")) %>% 
    mutate(media_url = as.character(media_url)) %>% 
    mutate(media_expanded_url = as.character(media_expanded_url)) %>% 
    mutate(mentions_screen_name = as.character(mentions_screen_name))

  return(deputados_merge)
}

fetch_tweets <- function() {
  ## access token method
  create_token(
    app = "",
    consumer_key = "",
    consumer_secret = "",
    access_token = "",
    access_secret = "")
}

install.packages("rtweet")
install.packages("jsonlite", repos="https://cran.rstudio.com/")
install.packages("lubridate")

library(jsonlite)
library(rtweet)
library(purrr)
library(tidyverse)
library(lubridate)

json_file <- 'https://datahub.io/jeffersonrpn/redes-sociais-parlamentares-brasil/datapackage.json'
json_data <- fromJSON(paste(readLines(json_file), collapse=""))

for(i in 1:length(json_data$resources$datahub$type)) {
  if(json_data$resources$datahub$type[i]=='derived/csv') {
    path_to_file = json_data$resources$path[i]
    data <- read.csv(url(path_to_file), stringsAsFactors = FALSE)
  }
}

get_user_timeline  <- function(username) {
  print(username)
  return(get_timelines(username, n = 500))
}

data_filtrada <- data %>% filter(!is.na(twitter) & twitter != "" & casa == 'câmara') %>% 
  slice(1:150)

twitter_data <- purrr::map_df(.x = data_filtrada$twitter, ~ get_user_timeline(.x))

teste <- lubridate::as_date(today())

twitter_data %>% 
  mutate(created_at_date = as_date(created_at)) %>% 
 filter(created_at_date >= lubridate::as_date(today()) - 30) %>% 
  group_by(user_id, screen_name) %>% 
  summarise(n = n(), data_minima = teste - 30, data_ultimo_tweet = max(created_at_date)) -> atividade

library("ggplot2")

atividade %>% ggplot(aes(x = n)) + geom_histogram(fill="tomato2", col="black", bins= 50) + theme_bw() +
  scale_x_continuous(breaks = seq(0, 600, 50))

atividade %>% filter(n<50) %>% ggplot(aes(x = n)) + geom_histogram(fill="tomato2", col="black", bins= 50) + theme_bw() +
  scale_x_continuous(breaks = seq(0, 50, 2))

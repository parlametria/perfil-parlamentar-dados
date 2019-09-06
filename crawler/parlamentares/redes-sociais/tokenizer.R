tweets_to_vec <- function(tweets_df) {
  library(tidyverse)
  library(tidytext)
  library(text2vec)
  
  source(here::here("crawler/utils/utils.R"))
  
  stopwords <- 
    read_csv(
    "https://gist.githubusercontent.com/alopes/5358189/raw/2107d809cca6b83ce3d8e04dbd9463283025284f/stopwords.txt",
    col_names = FALSE) %>% 
    pull(`X1`)
  
  tweets_df <- tweets_df %>% 
    mutate(text = padroniza_texto(text))
  
  tokens <- itoken(tweets_df$text, 
                     tokenizer = word_tokenizer, 
                     ids = tweets_df$id, 
                     progressbar = FALSE)
  
  vocabulary <- create_vocabulary(tokens, stopwords = stopwords)
  
  return(vocabulary)
}



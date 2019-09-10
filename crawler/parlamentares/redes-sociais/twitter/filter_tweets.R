#' @title Cria um vocabulário para um conjunto de textos
#' @description Recebe um dataframe contendo coluna `text` e retorna um dataframe contendo palavras,
#' total de ocorrências dessa palavra e número de documentos (rows da coluna `text`) que possuem cada palavra
#' @param df Dataframe contendo coluna `text`
#' @return Dataframe com as colunas term, term_count e doc_count
tweets_to_vec <- function(df) {
  library(tidyverse)
  library(tidytext)
  library(text2vec)
  library(here)
  
  source(here("crawler/utils/utils.R"))
  
  stopwords <- 
    read_csv(
    here("crawler/raw_data/stopwords.txt"),
    col_names = FALSE) %>% 
    pull(`X1`) %>% 
    padroniza_nome() %>% 
    tolower()
  
  df <- df %>% 
    mutate(text = padroniza_texto(text))
  
  tokens <- itoken(df$text, 
                     tokenizer = word_tokenizer, 
                     ids = df$id, 
                     progressbar = FALSE)
  
  vocabulary <- create_vocabulary(tokens, stopwords = stopwords)
  
  return(vocabulary)
}

#' @title Filtra os tweets que possuem palavras que Molon tweeta
#' @description Recebe um dataframe contendo coluna `text` e `nome_eleitoral` e 
#' filtra os textos que possuem palavras do vocabulário do deputado a ser filtrado
#' @param tweets Dataframe contendo coluna `text` e `nome_eleitoral`
#' @param nome_eleitoral_deputado Nome eleitoral do deputado a ser filtrado
#' @return Dataframes filtrado pelas palavras do vocabulário do deputado escolhido
filter_words_in_vocabulary <- function(tweets, nome_eleitoral_deputado = 'Alessandro Molon') {
  library(tidyverse)
  source(here::here("crawler/utils/utils.R"))
  
  vocabulario_molon <- tweets %>% 
    filter(nome_eleitoral == toupper(nome_eleitoral_deputado)) %>% 
    tweets_to_vec()
  
  vocabulario_molon <- vocabulario_molon %>% 
    filter(term_count > 1, doc_count > 1)
  
  tweets_filtered <- tweets %>% 
    mutate(processed_text = padroniza_texto(text)) %>% 
    filter(str_detect(processed_text, paste(vocabulario_molon$term, collapse = '|')))
  
  return(tweets_filtered)
  
}

#' @title Filtra os tweets que possuem palavras de um outro dataframe
#' @description Recebe um dataframe contendo coluna `text` e 
#' filtra os textos que possuem palavras do outro dataframe (formato regex)
#' @param tweets Dataframe contendo coluna `text`
#' @param keywords_datapath Caminho para o arquivo onde estão as palavras em formato regex
#' @return Dataframes filtrado
filter_words_by_keywords <- function(tweets, 
                                     keywords_datapath = here::here("crawler/raw_data/keywords_meio_ambiente.txt")) {
  library(tidyverse)
  
  keywords <- read_csv(
    keywords_datapath,
    col_names = FALSE) %>% 
    pull(`X1`)
  
  tweets_filtered <- tweets %>% 
    mutate(processed_text = padroniza_texto(text)) %>% 
    filter(str_detect(processed_text, paste(keywords, collapse = '|')))
  
  return(tweets_filtered)
}
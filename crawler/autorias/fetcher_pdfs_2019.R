library(pdftools)
library(tidyverse)

downloadPDF <- function(uri, filepath) {
  download.file(uri, filepath)
}

extractAutor <- function(id, filepath) {
  autor <- tryCatch({
    raw_text <- 
      pdftools::pdf_text(filepath) %>%
      strsplit("\n")
    #raw_text <- gsub("\n", "", raw_text)
    query <-
      stringr::str_extract(raw_text, 'Sala das Sessões.*') %>%
      stringr::str_remove_all('Sala das Sessões.* [\\d]{4}.') %>%
      stringr::str_remove_all('Disponível.*|Dep(\\.|utad(o|a))|[:punct:]') %>%
      stringr::str_extract('[a-zA-Z].*[a-zA-Z]*/[a-zA-Z]{2}')
    
    autor <- query[!is.na(query)]
    autor <- gsub("\", \"", "", autor)
    
    return(autor)
    }, 
    error = function(e){
      return(NA)
    })
  return(autor)
}

#teste  <- purrr::map2_df(df$id, df$filepath, ~ extractAutor(.x, .y))

processAutor <- function(uri, id, output_folder) {
  print(id)
  dir.create(file.path(output_folder, id), showWarnings = F)
  filepath <- paste0(output_folder, "/", id, "/", id, ".pdf")
  
  downloadPDF(uri, filepath)
  
  autor <- extractAutor(id, filepath)
  
  if(length(autor) > 0) {
    raw_df <- dplyr::tribble(~id, ~autor,
                     id, autor)
    return(raw_df)
  } 
  
  return(dplyr::tribble(~ id, ~ autor))
}

df <- readr::read_csv(here::here("crawler/raw_data/proposicoes_2019.csv"))
df <- df %>% 
  mutate(output_folder = here::here("crawler/raw_data/proposicoes"),
         filepath = paste0(output_folder, "/", id, "/", id, ".pdf"))

a <- purrr::pmap_df(list(df$uri, df$id, df$output_folder), processAutor)

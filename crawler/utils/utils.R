#' @title Padroniza os nomes, retirando acentos, cedilhas e colcoando todas as letras em uppercase
#' @description Recebe um nome e o padroniza no formato: sem acentos, cedilhas, letras maiúsculas
#' @param nome Nome a ser padronizado
#' @return Nome padronizado
#' @examples
#' padroniza_nome("çíço do álcórdéón")
padroniza_nome <- function(nome) {
  library(tidyverse)
  
  return(nome %>% 
           iconv(to="ASCII//TRANSLIT") %>% 
           toupper())
}

#' @title Padroniza texto, retirando links, menções, pontuações, retirando acentos, números,
#' cedilhas e colocando todas as letras em lowercase
#' @description Recebe um texto e o padroniza no formato: sem acentos, cedilhas, letras maiúsculas, links, números e menções
#' @param texto Texto a ser padronizado
#' @return Texto padronizado
#' @examples
#' padroniza_texto("çíço do álcórdéón")
padroniza_texto <- function(texto) {
  library(tidyverse)
  texto <- 
    gsub('http\\S+\\s*|(#|@)([a-z|A-Z|0-9|_])*|[[:punct:]]|[0-9]*',
         "", 
         texto) %>% 
    tolower()
  
  
  return(texto)
} 
#' @title Baixa um PDF a partir de uma url e um caminho de destino
#' @description A partir de uma url e de o caminho de destino + nome para o pdf, baixa e salva este arquivo
#' @param url URL da requisição
#' @param dest_path Caminho + nome do arquivo PDF que será baixado.
download_pdf <- function(url, dest_path = "votacao_senado.pdf") {
  pdf <- RCurl::getBinaryURL(url,  
                      ssl.verifypeer=FALSE)
  
  writeBin(pdf, dest_path)
}

#' @title Raspa os dados de votos de um pdf
#' @description A partir do caminho do pdf, raspa as informações referentes aos votos dos senadores
#' @param url URL da requisição
#' @param dest_path Caminho + nome do arquivo PDF que será baixado.
#' @return Dataframe com informações de votos dos senadores
scrap_votos_from_pdf_senado <- function(pdf_filepath) {
  library(tidyverse)
  
  pdf <- pdftools::pdf_text(pdf_filepath)
  
  votos <- purrr::map_df(pdf, function(x) {
    content <-
      str_extract(x, "(.|\n)+?(?=(\\s Legenda|PRESENTES))") %>%
      str_extract("SENADO.*UF.*VOTO(.|\n)*") %>%
      str_split("\n")
    
    data <- content[[1]] %>%
      str_split("\\s{2,}") %>%
      as.data.frame() %>%
      t() %>%
      as.data.frame()
    
    rownames(data) <- NULL
    
    if(ncol(data) > 1) {
      colnames(data) <- c('senador', 'uf', 'partido', 'voto')
      return(data %>% 
               slice(2:nrow(data)))
      
    } else{
      
      return(tribble(~ senador, ~ uf, ~ partido, ~ voto))
    }
   
  })
  
    return(votos)
} 

#' @title Deleta um arquivo
#' @description A partir do caminho de um arquivo, deleta-o do computador.
#' @param filepath Caminho do arquivo a ser removido.
delete_file <- function(filepath) {
  file.remove(filepath)
}

#' @title Extrai informações de votos dos senadores a partir de uma url
#' @description A partir de uma url, extrai os dados de votos dos senadores.
#' @param url URL da requisição
#' @return Dataframe com informações de votos dos senadores
fetch_votos_por_link_votacao_senado <- function(url) {
  library(RCurl)
  library(rvest)
  library(xml2)
 
  print(paste0("Extraindo informações de votação de id ", 
               str_extract(url, "\\d*$")))
  
  new_url <- 
    getURL(url, 
           ssl.verifypeer = FALSE) %>% 
    read_html() %>% 
    html_node('a') %>% 
    html_attr('href')
  
  pdf_filepath <- here::here("crawler/votacoes/votos/votacao_senado.pdf")
  
  download_pdf(new_url, pdf_filepath)
  
  votos <- scrap_votos_from_pdf_senado(pdf_filepath)
  
  delete_file(pdf_filepath)
  
  
  return(votos)
} 

#' @title Extrai informações de votos dos senadores a partir de um conjutno de votações
#' @description A partir de um dataframe de votações, extrai os dados de votos dos senadores.
#' @param votacoes_senado_filepath Caminho para o csv das votações
#' @return Dataframe com informações de votos dos senadores
fetch_all_votos_senado <- function(votacoes_senado_filepath = NULL) {
  library(tidyverse)
  
  if (is.null(votacoes_senado_filepath)) {
    source(here::here("crawler/votacoes/fetcher_votacoes_senado.R"))
    votacoes <- fetcher_votacoes_por_intervalo_senado()
  } else {
    votacoes <- read_csv(votacoes_senado_filepath)
  }
  
  votacoes <- votacoes %>% 
    filter(votacao_secreta == 0) %>% 
    mutate(ano = lubridate::year(datetime))
  
  votos <- 
    tibble::tibble(
      id_proposicao = votacoes$id_proposicao,
      id_votacao = votacoes$id_votacao,
      ano = votacoes$ano,
      url = votacoes$link_votacao,
      casa = "senado") %>% 
    mutate(dados = purrr::map(
      url,
      fetch_votos_por_link_votacao_senado)) %>% 
    unnest(dados) %>% 
    filter(senador != '')
  
  return(votos)
  
}
#' @title Processa dados de votos e orientações para sumarizar aderência do parlamentar ao partido
#' @description Processa os dados dos mandatos para os parlamentares
#' @param votos_path Caminho para o arquivo de dados de votos na legislatura atual
#' @param orientacoes_path Caminho para o arquivo de dados de orientações na legislatura atual
#' @param parlamentares_path Caminho para o arquivo de dados dos parlamentares
#' @return Dataframe com informações de aderência
processa_aderencia <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/aderencia/analyzer_aderencia.R"))
  
  aderencia_camara <- processa_aderencia_parlamentares(selecionadas = 0, casa = "camara")
  
  aderencia_senado <- processa_aderencia_parlamentares(selecionadas = 0, casa = "senado")
  
  aderencia_alt <- aderencia_camara %>% 
    rbind(aderencia_senado)
  
  return(aderencia_alt)
}
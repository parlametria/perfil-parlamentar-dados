#' @title Processa dados das composições das comissões
#' @description Processa os dados das composições das comissões e retorna no formato  a ser utilizado pelo banco de dados
#' @param composicao_path Caminho para o arquivo de dados de composições das comissões sem tratamento
#' @param deputados_path Caminho para o arquivo de dados de composições dos deputados para mapear id ao cpf
#' @return Dataframe com informações das composições das comissões
processa_composicao_comissoes <- function(composicao_path = here::here("crawler/raw_data/composicao_comissoes.csv")) {
  library(tidyverse)
  library(here)
  library(digest)
  
  composicao_comissoes <- readr::read_csv(composicao_path, col_types = cols(comissao_id = "i", id_parlamentar = "i"))
  
  composicao_comissoes_mapped <- composicao_comissoes %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                              id_parlamentar)) %>%
    dplyr::mutate(id_comissao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                           comissao_id)) %>%
    dplyr::rowwise(.) %>% 
    dplyr::mutate(concat_chave_periodo = paste0(data_inicio, " ", data_fim)) %>%
    dplyr::mutate(id_periodo = digest::digest(concat_chave_periodo, algo="md5", serialize=F)) %>% 
    dplyr::ungroup() %>% 
    dplyr::select(id_comissao_voz, id_parlamentar_voz, id_periodo, cargo, situacao, data_inicio, data_fim, is_membro_atual)
  
  return(composicao_comissoes_mapped)  
}
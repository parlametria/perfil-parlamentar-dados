#' @title Carrega respostas dos candidatos
#' @description Lê os dados de respostas dos candidatos e processa o tipo das datas utilizado
#' @param data_path Caminho para o arquivo de respostas sem tratamento.
#' @return Dataframe com as respostas e o tratamento para as datas
carrega_respostas <- function(data_path = here::here("crawler/raw_data/respostas.csv")){
  library(tidyverse)
  library(here)
  
  respostas <- read.csv(data_path, stringsAsFactors = FALSE, colClasses = c("cpf" = "character")) %>% 
    dplyr::mutate(date_modified = as.POSIXct(date_modified, format = "%Y-%m-%dT%H:%M:%S"), tz = "GMT") %>% 
    dplyr::mutate(date_modified = 
                    dplyr::if_else(is.na(date_modified),
                                   as.POSIXct("2000-01-01T01:01:01+00:00", 
                                              format = "%Y-%m-%dT%H:%M:%S", 
                                              tz = "GMT"),
                                   date_modified
                    )
    ) %>% 
    dplyr::mutate(date_created = as.POSIXct(date_created,
                                            format = "%Y-%m-%dT%H:%M:%S", 
                                            tz = "GMT")) %>% 
    dplyr::mutate(date_created = 
                    dplyr::if_else(is.na(date_created),
                                   as.POSIXct("2000-01-01T01:01:01+00:00", 
                                              format = "%Y-%m-%dT%H:%M:%S", 
                                              tz = "GMT"),
                                   date_created
                    )
    ) %>% 
    select(-tz)
  
  return(respostas)
}

#' @title Processa respostas dos candidatos
#' @description Processa os dados de respostas dos candidatos (extraídos do monkey) e retorna no formato correto para o banco de dados
#' @param res_data_path Caminho para o arquivo de respostas sem tratamento.
#' @param parlamentares_path Caminho para o arquivo de parlamentares
#' @return Dataframe com id, resposta, cpf, pergunta_id 
processa_respostas <- function(res_data_path = here::here("crawler/raw_data/respostas.csv"),
                               parlamentares_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("bd/processor/parlamentares/processa_parlamentares.R"))
  
  respostas <- carrega_respostas(res_data_path)
  parlamentares <- processa_parlamentares(parlamentares_path) %>%
    dplyr::select(id_parlamentar_voz, cpf)

  respostas_alt <- respostas %>% 
    unique() %>% ## linhas exatamente iguais são eliminadas
    dplyr::group_by(cpf) %>% 
    dplyr::mutate(last_date_modified = max(date_modified)) %>% 
    dplyr::ungroup() %>% 
    dplyr::filter(date_modified == last_date_modified) %>% ## observações com a última data de atualização são utilizadas
    dplyr::distinct(cpf, .keep_all = TRUE) %>%
    dplyr::select(cpf, dplyr::starts_with("respostas.")) %>% 
    dplyr::select(-c(respostas.129411238, respostas.129520614, respostas.129521027)) %>% 
    tidyr::gather(key = "pergunta_id", 
                  value = "resposta", 
                  dplyr::starts_with("respostas.")) %>% 
    dplyr::mutate(pergunta_id = substring(pergunta_id, nchar("respostas.") + 1)) %>% 
    dplyr::mutate(pergunta_id = as.numeric(pergunta_id)) %>% 
    dplyr::mutate(resposta = dplyr::if_else(is.na(resposta), 0, as.numeric(resposta))) %>% 
    tibble::rowid_to_column(var = "id") %>% 
    dplyr::inner_join(parlamentares, by="cpf") %>% 
    dplyr::select(id, resposta, id_parlamentar_voz, pergunta_id)
  
  return(respostas_alt)
}
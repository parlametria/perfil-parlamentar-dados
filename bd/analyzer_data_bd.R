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
#' @return Dataframe com id, resposta, cpf, pergunta_id 
processa_respostas <- function(res_data_path = here::here("crawler/raw_data/respostas.csv")) {
  library(tidyverse)
  library(here)
  
  respostas <- carrega_respostas(res_data_path)
  
  respostas_alt <- respostas %>% 
    dplyr::select(cpf, dplyr::starts_with("respostas.")) %>% 
    dplyr::select(-c(respostas.129411238, respostas.129520614, respostas.129521027)) %>% 
    
    tidyr::gather(key = "pergunta_id", 
                  value = "resposta", 
                  dplyr::starts_with("respostas.")) %>% 
    dplyr::mutate(pergunta_id = substring(pergunta_id, nchar("respostas.") + 1)) %>% 
    dplyr::mutate(pergunta_id = as.numeric(pergunta_id)) %>% 
    dplyr::mutate(resposta = dplyr::if_else(is.na(resposta), 0, as.numeric(resposta))) %>% 
    tibble::rowid_to_column(var = "id") %>% 
    
    dplyr::select(id, resposta, cpf, pergunta_id)
  
  return(respostas_alt)
}

#' @title Processa dados dos candidatos
#' @description Processa os dados dos candidatos e retorna no formato correto para o banco de dados
#' @param cand_data_path Caminho para o arquivo de dados dos candidatos sem tratamento
#' @param res_data_path Caminho para o arquivo de respostas sem tratamento.
#' @return Dataframe com informações detalhadas dos candidatos
processa_candidatos <- function(cand_data_path = here::here("crawler/raw_data/candidatos.csv"),
                                res_data_path = here::here("crawler/raw_data/respostas.csv"),
                                parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  candidatos <- read.csv(cand_data_path, stringsAsFactors = FALSE, colClasses = c("cpf" = "character"))
  respostas <- carrega_respostas(res_data_path)
  parlamentares <- read.csv(parlamentares_data_path, stringsAsFactors = FALSE, colClasses = c("cpf" = "character"))
    
  ## Lidando com candidatos que responderam mais de uma vez
  respostas_alt <- respostas %>% 
    unique() %>% ## linhas exatamente iguais são eliminadas
    dplyr::group_by(cpf) %>% 
    dplyr::mutate(last_date_modified = max(date_modified)) %>% 
    dplyr::ungroup() %>% 
    dplyr::filter(date_modified == last_date_modified) %>% ## observações com a última data de atualização são utilizadas
    dplyr::distinct(cpf, .keep_all = TRUE) %>%  ## Filtra restante das respostas duplicadas (todas de candidatos que não responderam ao questionário)
    dplyr::select("cpf", "tem_foto", "recebeu", "n_candidatura", "eleito", "respondeu")
  
 candidatos_completo <- candidatos %>%  
   dplyr::right_join(respostas_alt, by = "cpf") %>% 
   dplyr::distinct(cpf, .keep_all = TRUE) %>% 
   dplyr::select("estado", "uf", "idade_posse", "nome_coligacao", "nome_candidato", "cpf", "recebeu", "num_partido",
          "email", "nome_social", "nome_urna", "reeleicao", "ocupacao", "nome_exibicao", "raca", "tipo_agremiacao",
          "n_candidatura", "composicao_coligacao", "tem_foto", "partido", "sg_partido", "grau_instrucao",
          "genero", "eleito", "respondeu") %>% 
   dplyr::left_join(parlamentares %>% dplyr::select(cpf, id), by = c("cpf")) %>% 
   dplyr::rename(id_parlamentar = id)
 
 return(candidatos_completo)
}

#' @title Processa dados de perguntas
#' @description Processa os dados de perguntas e adiciona o id do tema da pergunta
#' @param perg_data_path Caminho para o arquivo de dados de perguntas sem tratamento
#' @return Dataframe com informações das perguntas incluindo o id do tema da pergunta
processa_perguntas <- function(perg_data_path = here::here("crawler/raw_data/perguntas.csv")) {
  library(tidyverse)
  library(here)
  
  perguntas <- read.csv(perg_data_path, stringsAsFactors = FALSE)
  
  perguntas_alt <- perguntas %>% 
    dplyr::mutate(tema_id = dplyr::case_when(
      tema == "Meio Ambiente" ~ 0,
      tema == "Direitos Humanos" ~ 1,
      tema == "Integridade e Transparência" ~ 2,
      tema == "Nova Economia" ~ 3,
      tema == "Transversal" ~ 4,
      TRUE ~ 5
    )) %>% 
    dplyr::select(texto, id, tema_id)

  return(perguntas_alt)
}

#' @title Cria dados dos temas
#' @description Cria os dados dos temas
#' @return Dataframe com informações dos temas (descrição e id)
processa_temas <- function() {
  temas <- data.frame(id = 0:5,
                      tema = c("Meio Ambiente", 
                        "Direitos Humanos", 
                        "Integridade e Transparência", 
                        "Agenda Nacional", 
                        "Transversal", 
                        "Educação"), 
                      slug = c("meio-ambiente",
                               "direitos-humanos",
                               "transparencia",
                               "agenda-nacional",
                               "transversal",
                               "educacao"),
                      stringsAsFactors = FALSE)
  
  return(temas)
}

#' @title Processa dados de proposições
#' @description Processa os dados de proposições e adiciona o id do tema da proposição
#' @param prop_data_path Caminho para o arquivo de dados de perguntas sem tratamento
#' @return Dataframe com informações das proposições incluindo o id do tema da proposição
processa_proposicoes <- function(prop_data_path = here::here("crawler/raw_data/tabela_votacoes.csv")) {
  library(tidyverse)
  library(here)
  
  proposicoes <- read.csv(prop_data_path, stringsAsFactors = FALSE)
  
  proposicoes_alt <- proposicoes %>% 
    dplyr::mutate(tema_id = dplyr::case_when(
      tema == "Meio Ambiente" ~ 0,
      tema == "Direitos Humanos" ~ 1,
      tema == "Integridade e Transparência" ~ 2,
      tema == "Agenda Nacional" ~ 3,
      tema == "Transversal" ~ 4,
      TRUE ~ 5
    )) %>% 
    dplyr::select(-tema) %>% 
    dplyr::distinct(id_votacao, .keep_all= TRUE) %>% 
    dplyr::filter(!is.na(id_votacao)) %>% 
    dplyr::mutate(id_proposicao = as.character(id_proposicao)) %>% 
    dplyr::mutate(status_proposicao = "Ativa") %>% 
    dplyr::select("numero_proj_lei", "id_votacao", "titulo", "descricao", "tema_id", "status_proposicao", "id_proposicao")
  
  return(proposicoes_alt)
}

#' @title Processa dados de votações
#' @description Processa os dados de votações e retorna no formato  a ser utilizado pelo banco de dados
#' @param vot_data_path Caminho para o arquivo de dados de votações sem tratamento
#' @return Dataframe com informações das votações
processa_votacoes <- function(vot_data_path = here::here("crawler/raw_data/votacoes.csv")) {
  library(tidyverse)
  library(here)
  
  votacoes <- read.csv(vot_data_path, stringsAsFactors = FALSE, colClasses = c("cpf" = "character"))
  
  candidatos <- processa_candidatos(cand_data_path = here::here("crawler/raw_data/candidatos.csv"),
                                    res_data_path = here::here("crawler/raw_data/respostas.csv"))
  
  candidatos_list <- candidatos %>% dplyr::pull(cpf)
  
  ## Filtra apenas as votações dos candidatos que foram candidatos nas eleições de 2018 (dataframe candidatos)
  votacoes_filtered <- votacoes %>% 
    dplyr::filter(cpf %in% candidatos_list) %>% 
    tibble::rowid_to_column(var = "id") %>% 
    dplyr::select(id, resposta = voto, cpf, votacao_id = id_votacao)
    
  return(votacoes_filtered)  
}

#' @title Processa dados de comissões
#' @description Processa os dados de comissões e retorna no formato  a ser utilizado pelo banco de dados
#' @param comissoes_data_path Caminho para o arquivo de dados de comissões sem tratamento
#' @return Dataframe com informações das comissões
processa_comissoes <- function(comissoes_data_path = here::here("crawler/raw_data/comissoes.csv")) {
  library(tidyverse)
  library(here)
  
  comissoes <- readr::read_csv(comissoes_data_path, col_types = cols(id = "i")) %>% 
    dplyr::mutate(id_comissao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                              id)) %>%
    dplyr::select(id_comissao_voz, id, casa, sigla, nome)
  
  return(comissoes)
}

#' @title Processa dados das composições das comissões
#' @description Processa os dados das composições das comissões e retorna no formato  a ser utilizado pelo banco de dados
#' @param composicao_path Caminho para o arquivo de dados de composições das comissões sem tratamento
#' @param deputados_path Caminho para o arquivo de dados de composições dos deputados para mapear id ao cpf
#' @return Dataframe com informações das composições das comissões
processa_composicao_comissoes <- function(composicao_path = here::here("crawler/raw_data/composicao_comissoes.csv")) {
  library(tidyverse)
  library(here)
  
  composicao_comissoes <- readr::read_csv(composicao_path, col_types = cols(comissao_id = "i", id_parlamentar = "i"))
  
  composicao_comissoes_mapped <- composicao_comissoes %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                              id_parlamentar)) %>%
    dplyr::mutate(id_comissao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                           comissao_id)) %>%
    dplyr::select(id_comissao_voz, id_parlamentar_voz, cargo, situacao)

  return(composicao_comissoes_mapped)  
}
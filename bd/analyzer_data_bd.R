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

#' @title Processa dados dos parlamentares
#' @description Processa os dados dos parlamentares e retorna no formato correto para o banco de dados
#' @param parlamentares_data_path Caminho para o arquivo de dados dos parlamentares sem tratamento
#' @return Dataframe com informações detalhadas dos parlamentares
processa_parlamentares <- function(parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  parlamentares <- read.csv(parlamentares_data_path, stringsAsFactors = FALSE, colClasses = c("cpf" = "character"))
  
  parlamentares_partidos <- parlamentares %>% 
    group_by(sg_partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    dplyr::mutate(id_partido = map_sigla_id(sg_partido)) %>% 
    ungroup()
  
  parlamentares_alt <- parlamentares %>%
    dplyr::mutate(id_parlamentar_voz = paste0(
                   dplyr::if_else(casa == "camara", 1, 2), 
                   id)) %>% 
    left_join(parlamentares_partidos %>% select(id_partido, sg_partido), by = c("sg_partido")) %>% 
    dplyr::select(id_parlamentar_voz, 
                  id_parlamentar = id,
                  casa, 
                  cpf, 
                  nome_civil, 
                  nome_eleitoral, 
                  genero, 
                  uf, 
                  id_partido, 
                  situacao, 
                  condicao_eleitoral, 
                  ultima_legislatura, 
                  em_exercicio)
 
  return(parlamentares_alt)
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
  temas <- data.frame(id_tema = c(0, 1, 2, 3, 5, 99),
                      tema = c("Meio Ambiente", 
                        "Direitos Humanos", 
                        "Integridade e Transparência", 
                        "Agenda Nacional", 
                        "Educação",
                        "Geral"), 
                      slug = c("meio-ambiente",
                               "direitos-humanos",
                               "transparencia",
                               "agenda-nacional",
                               "educacao",
                               "geral"),
                      ativo = c(1, 1, 1, 1, 1, 0),
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
  source(here("crawler/proposicoes/fetch_proposicoes_voz_ativa.R"))
  
  proposicoes_questionario <- fetch_proposicoes_questionario()
  
  proposicoes_plenario <- fetch_proposicoes_plenario_selecionadas()
  
  proposicoes <- proposicoes_questionario %>% 
    rbind(proposicoes_plenario) %>% 
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>% 
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    select(-n_prop) %>% 
    mutate(id_proposicao = as.numeric(id_proposicao))
  
  return(proposicoes)
}

#' @title Processa dados dos temas das proposições
#' @description Processa os dados dos temas de proposições
#' @return Dataframe com informações dos temas das proposições (cada tema para cada proposição é uma observação)
processa_proposicoes_temas <- function() {
  library(tidyverse)
  library(here)
  
  source(here("crawler/proposicoes/process_proposicao_tema.R"))
  
  proposicoes_questionario <- process_proposicoes_questionario_temas()
  
  proposicoes_plenario <- process_proposicoes_plenario_selecionadas_temas()
  
  proposicoes <- proposicoes_questionario %>%
    rbind(proposicoes_plenario) %>%
    mutate(id_tema = tema_id) %>% 
    distinct(id_proposicao, id_tema)
  
  return(proposicoes)
}

#' @title Processa dados de votos
#' @description Processa os dados de votos e retorna no formato  a ser utilizado pelo banco de dados
#' @param votos_posicoes_data_path Caminho para o arquivo de dados de votos das posições do questionário VA
#' @param votos_va_data_path Caminho para o arquivo de dados de votos das proposições selecionadas na legislatura Atual
#' @param parlamentares_path Caminho para o arquivo de dados de parlamentares
#' @return Dataframe com informações das votos
processa_votos <- function(votos_posicoes_data_path = here::here("crawler/raw_data/votos_posicoes.csv"),
                           votos_va_data_path = here::here("crawler/raw_data/votos.csv"),
                           parlamentares_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  votos_posicoes <- read_csv(votos_posicoes_data_path, col_types = cols(id_parlamentar = "i", id_votacao = "i", voto = "i")) %>% 
    select(id_votacao, id_parlamentar, casa, voto)
  
  votos_va <- read_csv(votos_va_data_path, col_types = cols(id_parlamentar = "i", id_votacao = "i", voto = "i")) %>% 
    select(id_votacao, id_parlamentar, casa, voto)
  
  votacoes <- votos_posicoes %>% 
    rbind(votos_va) %>% 
    distinct(id_votacao, id_parlamentar, .keep_all = TRUE)
  
  deputados <- read_csv(parlamentares_path, col_types = cols(id = "c")) %>% 
    filter(casa == "camara")
    
  votacoes_select <- votacoes %>%
    filter(id_parlamentar %in% (deputados %>% pull(id))) %>% ## garante que apenas deputados com info tenham seus votos salvos
    dplyr::mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                         id_parlamentar)) %>% 
    dplyr::select(id_votacao, id_parlamentar_voz, voto)
  
  return(votacoes_select)
}

#' @title Cria tabela de orientações
#' @description Cria tabela com as orientações dos partidos para votações realizadas em 2019
#' @param orientacoes_data_path Caminho para o arquivo de dados de orientações
#' @return Dataframe com informações das orientações
processa_orientacoes <- function(votos_path = here::here("crawler/raw_data/votos.csv"),
                                 orientacoes_data_path = here::here("crawler/raw_data/orientacoes.csv")) {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  source(here::here("crawler/votacoes/votos_orientacao/processa_dados_aderencia.R"))
  
  votos <- read_csv(votos_path, col_types = cols(.default = "c", id_votacao = "i", voto = "i"))
  
  orientacoes <- read_csv(orientacoes_data_path, col_types = cols(id_proposicao = "c", 
                                                                  id_votacao = "i", voto = "i"))
  
  orientacoes_governo <- orientacao_governo_pelo_voto_lider(votos, orientacoes)
  
  orientacoes_partidos <- orientacoes %>% 
    filter(tolower(partido) != "governo") %>% 
    rbind(orientacoes_governo) %>% 
    group_by(partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    dplyr::mutate(id_partido = map_sigla_id(partido)) %>% 
    ungroup()
  
  orientacoes_alt <- orientacoes %>% 
    filter(tolower(partido) != "governo") %>% 
    rbind(orientacoes_governo) %>% 
    select(id_votacao, partido, voto) %>% 
    left_join(orientacoes_partidos %>% select(partido, id_partido), by = c("partido")) %>% 
    select(id_votacao, id_partido, voto)
  
  return(orientacoes_alt)
}

#' @title Cria tabela de votações que conecta id das votações aos ids das proposições
#' @description Cria tabela de votações que conecta id das votações aos ids das proposições
#' @param votos_posicoes_data_path Caminho para o arquivo de dados de votos das posições do questionário VA
#' @param votos_va_data_path Caminho para o arquivo de dados de votos das proposições selecionadas na legislatura Atual
#' @return Dataframe com informações dos links id_votacao e id_proposicao
processa_votacoes <- function(votos_posicoes_data_path = here::here("crawler/raw_data/votos_posicoes.csv"),
                              votos_va_data_path = here::here("crawler/raw_data/votos.csv"),
                              votacoes_info_data_path = here::here("crawler/raw_data/votacoes_info.csv")) {
  library(tidyverse)
  library(here)
  
  votos_posicoes <- read_csv(votos_posicoes_data_path, col_types = cols(id_proposicao = "c", 
                                                                        id_parlamentar = "i", 
                                                                        id_votacao = "i", 
                                                                        voto = "i")) %>% 
    distinct(id_proposicao, id_votacao) %>% 
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>%
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    select(id_proposicao, id_votacao)
  
  votos_va <- read_csv(votos_va_data_path, col_types = cols(id_proposicao = "c", 
                                                            id_parlamentar = "i", 
                                                            id_votacao = "i", 
                                                            voto = "i")) %>% 
    select(id_proposicao, id_votacao)
  
  votacoes_info <- read_csv(votacoes_info_data_path, col_types = cols(id_proposicao = "c", 
                                                                      id_votacao = "i"))
  
  votacoes <- votos_posicoes %>% 
    rbind(votos_va) %>% 
    rbind(tibble(id_proposicao = "46249", id_votacao = 99999)) %>% ## ID especial para a PL 6299/2002
    distinct(id_proposicao, id_votacao) %>% 
    left_join(votacoes_info, by = c("id_proposicao", "id_votacao"))
  
  return(votacoes)
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

#' @title Processa dados dos mandatos
#' @description Processa os dados dos mandatos e retorna no formato  a ser utilizado pelo banco de dados
#' @param mandatos_path Caminho para o arquivo de dados de mandatos sem tratamento
#' @return Dataframe com informações dos mandatos
processa_mandatos <- function(mandatos_path = here::here("crawler/raw_data/mandatos.csv")) {
  library(tidyverse)
  
  mandatos <- read.csv(mandatos_path, stringsAsFactors = FALSE)
  
  mandatos <- mandatos %>% 
    dplyr::mutate(casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id_parlamentar))) %>% 
    dplyr::select(-c(casa_enum, id_parlamentar, casa)) %>% 
    dplyr::select(id_parlamentar_voz, 
                  id_legislatura, data_inicio, data_fim, situacao, 
                  cod_causa_fim_exercicio, desc_causa_fim_exercicio)
  return(mandatos)
}

#' @title Processa dados dos mandatos
#' @description Processa os dados dos mandatos e retorna no formato  a ser utilizado pelo banco de dados
#' @param mandatos_path Caminho para o arquivo de dados de mandatos sem tratamento
#' @return Dataframe com informações dos mandatos
processa_liderancas <- function(liderancas_path = here::here("crawler/raw_data/liderancas.csv")) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  liderancas <- read_csv(liderancas_path)
  
  liderancas <- liderancas %>%
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id)),
      bloco_partido = gsub("Bloco ", "", bloco_partido)
    ) %>%
    select(id_parlamentar_voz, cargo, partido = bloco_partido) %>% 
    map_sigla_to_id() %>% 
    select(id_parlamentar_voz, id_partido, cargo)
  
  return(liderancas)
}

#' @title Processa dados de votos e orientações para sumarizar aderência do parlamentar ao partido
#' @description Processa os dados dos mandatos para os parlamentares
#' @param votos_path Caminho para o arquivo de dados de votos na legislatura atual
#' @param orientacoes_path Caminho para o arquivo de dados de orientações na legislatura atual
#' @param parlamentares_path Caminho para o arquivo de dados dos parlamentares
#' @return Dataframe com informações de aderência
processa_aderencia <- function(votos_path = here::here("crawler/raw_data/votos.csv"),
                               orientacoes_path = here::here("crawler/raw_data/orientacoes.csv"),
                               parlamentares_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/utils_votacoes.R"))
  source(here("crawler/votacoes/votos_orientacao/processa_dados_aderencia.R"))
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  ## Preparando dados de votos, orientações e deputados
  votos <- read_csv(votos_path, col_types = cols(.default = "c", voto = "i"))
  
  orientacoes <- read_csv(orientacoes_path, col_types = cols(.default = "c", voto = "i"))
  
  deputados <- read_csv(parlamentares_path, col_types = cols(id = "c")) %>% 
    filter(casa == "camara")
  
  ## Preparando dados de proposições e seus respectivos temas
  proposicoes <- processa_proposicoes()
  
  proposicoes_temas <- processa_proposicoes_temas()
  
  proposicoes <- proposicoes %>% 
    filter(status_importante == "Ativa")
  
  proposicoes_temas <- proposicoes_temas %>% 
    filter(id_proposicao %in% (proposicoes %>% pull(id_proposicao)))
    
  temas <- processa_temas()
  
  ## Calcula aderência por tema
  aderencia_temas <- processa_dados_aderencia_temas(proposicoes_temas, temas, 
                                                    votos, orientacoes, deputados, filtrar = FALSE) %>% 
    map_sigla_to_id() %>% 
    select(id_tema, id_deputado, nome, id_partido, faltou, partido_liberou,
           nao_seguiu, seguiu, total_votacoes, freq)
    
  
  ## Calcula aderência geral ao Partido
  aderencia_geral_partido <- processa_dados_deputado_aderencia(votos, orientacoes, 
                                                               deputados, filtrar = FALSE)[[2]] %>%
    map_sigla_to_id() %>% 
    mutate(id_tema = 99) %>% 
    select(id_tema, id_deputado, nome, id_partido, faltou, partido_liberou,
           nao_seguiu, seguiu, total_votacoes, freq)
    
  ## Calcula aderência geral ao Governo
  aderencia_geral_governo <- processa_dados_deputado_aderencia_governo(votos, orientacoes, 
                                                                       deputados, filtrar = FALSE)[[2]] %>% 
    mutate(id_partido = 0) %>% 
    mutate(id_tema = 99) %>% 
    select(id_tema, id_deputado, nome, id_partido, faltou, partido_liberou,
           nao_seguiu, seguiu, total_votacoes, freq)
  
  aderencia_alt <- aderencia_geral_partido %>% 
    rbind(aderencia_geral_governo) %>% 
    rbind(aderencia_temas) %>% 
    mutate(casa_enum = 1, # 1 é o código da camara. TODO: estender para senadores
           id_parlamentar_voz = paste0(casa_enum, as.character(id_deputado))) %>% 
    mutate(freq = if_else(freq == -1, -1, freq / 100)) %>% 
    select(id_parlamentar_voz, id_partido, id_tema, faltou, partido_liberou, nao_seguiu, seguiu, aderencia = freq)
  
  return(aderencia_alt)
}

#' @title Processa dados dos partidos
#' @description Processa os dados dos partidos políticos
#' @param partidos_path Caminho para o arquivo de dados dos partidos
#' @return Dataframe com informações de partidos
processa_partidos <- function(partidos_path = here::here("crawler/raw_data/partidos.csv")) {
  partidos <- readr::read_csv(partidos_path)
  return(partidos)
}
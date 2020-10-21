#' @title Recupera e processa dados de uma proposição
#' @description A partir de um id, retorna os dados de uma proposição
#' @param id_proposicao ID da proposição
#' @return Dataframe com os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_senado(id_proposicao)
fetch_proposicoes_senado <- function(id_proposicao) {
  library(tidyverse)
  
  cat(paste0("Baixando dados de proposição de id ", id_proposicao, "...\n"))
  
  proposicao <- tryCatch({
    rcongresso::fetch_proposicao_senado(id_proposicao) %>%
      select(
        id = codigo_materia,
        data_apresentacao,
        nome = descricao_identificacao_materia,
        ementa = ementa_materia,
        tema = assunto_especifico,
        autor = autor_nome
      ) %>%
      mutate(
        uri_tramitacao =
          paste0(
            "https://www25.senado.leg.br/web/atividade/materias/-/materia/",
            id_proposicao
          )
      )
  }, error = function(e) {
    return(tribble(
      ~ id,
      ~ data_apresentacao,
      ~ nome,
      ~ ementa,
      ~ tema,
      ~ autor,
      ~ uri_tramitacao
    ))
  })
  return(proposicao)
}

#' @title Recupera os temas de uma proposição específica
#' @description Especialização de fetch_proposicoes_senado, necessaria para mapeamento específico,
#' no caso em questão somente para os temas
#' @param id_proposicao ID da proposição
#' @return Lista com os dados do tema da proposição
fetch_tema_proposicoes_senado <- function(id_proposicao){
  proposicao <- fetch_proposicoes_senado(id_proposicao)
  if (nrow(proposicao) == 0) {
    return(NA)
  }
  return(proposicao$tema)
}

#' @title Recupera os nomes de uma proposição específica
#' @description Especialização de fetch_proposicoes_senado, necessaria para mapeamento específico,
#' no caso em questão somente para os nomes
#' @param id_proposicao ID da proposição
#' @return Lista com os dados do nome da proposição
fetch_nome_proposicoes_senado <- function(id_proposicao){
  proposicao <- fetch_proposicoes_senado(id_proposicao)
  if (nrow(proposicao) == 0) {
    return(NA)
  }
  return(proposicao$nome)
}

#' @title Recupera e processa dados de um conjunto de proposições
#' @description A partir de uma lista de ids, retorna os dados das respectivas proposições
#' @param ids lista de ids de proposições
#' @return Dataframe com os dados de proposições
#' @examples
#' proposicoes <- fetch_all_proposicoes(ids)
fetch_all_proposicoes <- function(ids) {
  proposicoes <-purrr::map_df(ids, ~ fetch_proposicoes_senado(.x))
  return(proposicoes)
}

#' @title Recupera e processa dados de um conjunto de proposições que tiveram votações nominais em plenário em um intervalo
#' @description Retorna os dados das proposições que tiveram votações nominais em plenário em um intervalo
#' @param initial_date Data inicial (formato "dd/mm/yyyy")
#' @param end_date Data final (formato "dd/mm/yyyy")
#' @return Dataframe com os dados de proposições do intervalo
#' @examples
#' proposicoes <- fetch_all_proposicoes_votadas_em_intervalo_senado()
fetch_all_proposicoes_votadas_em_intervalo_senado <- function(initial_date = "01/02/2019", 
                                                              end_date = format(Sys.Date(), "%d/%m/%Y")) {
  library(tidyverse)
  source(here::here("crawler/votacoes/fetcher_votacoes_senado.R"))
  
  votacoes <- 
    fetcher_votacoes_por_intervalo_senado(initial_date, end_date) %>% 
    select(id_proposicao) %>% unique()
  
  proposicoes <-
    purrr::map_df(votacoes$id_proposicao, ~ fetch_proposicoes_senado(.x))
  
  return(proposicoes)
}

#' @title Recupera e processa dados de um conjunto de proposições que tiveram votações nominais em plenário disponíveis em uma url
#' @description Retorna os dados das proposições que tiveram votações nominais em plenário disponíveis em uma url do csv
#' @param url URL do arquivo csv
#' @return Dataframe com os dados de proposições
#' @examples
#' proposicoes <- fetch_proposicoes_plenario_selecionadas_senado()
fetch_proposicoes_plenario_selecionadas_senado <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_SENADO
  }
  
  proposicoes <- read_csv(url, col_types = cols(id = "c")) %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    mutate(descricao = NA,
           status_proposicao = "Inativa",
           status_importante = "Ativa",
           casa = "senado") %>%
    select(id_proposicao = id, 
           casa, 
           projeto_lei = nome, 
           titulo = `Sugestões de apelido`, 
           descricao, 
           status_proposicao, 
           status_importante)
  
  return(proposicoes)
}

#' @title Captura as proposições de interesse a partir da casa
#' @description Com base nos parâmetros de selecionar proposições e de qual casa de interesse realiza a seleção
#' @param selecionadas Flag para expressar se deseja somente as proposições selecionadas
#' @param casa_aderencia Casa para a seleção das proposições (pode ser "camara" ou "senado)
#' @param proposicoes_url URL para a tabela de proposições com informações dos temas no VA
#' @return Dataframe contendo informações sobre as proposições
fetch_proposicoes <- 
  function(selecionadas = 1, 
           casa_aderencia = "camara", 
           proposicoes_url = NULL) {
    
    source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
    
    if (is.null(proposicoes_url)) {
      if (casa_aderencia == "camara") {
        proposicoes_url <- .URL_PROPOSICOES_PLENARIO_CAMARA
      } else {
        proposicoes_url <- .URL_PROPOSICOES_PLENARIO_SENADO
      }
    }
    
    proposicoes_selecionadas <-
      fetch_proposicoes_plenario_selecionadas_senado(proposicoes_url)
    
    proposicoes <- proposicoes_selecionadas %>%
      filter(status_importante == "Ativa")
    
    if (selecionadas == 0) {
      proposicoes <- fetch_proposicoes_plenario(casa_aderencia) 
      
      proposicoes <- proposicoes_selecionadas %>% 
        rbind(proposicoes) %>%
        distinct(id_proposicao, .keep_all = TRUE)
    }
    
    return(proposicoes)
  }


#' @title Recupera e processa dados de todas as proposições que tiveram votações nominais da casa em plenário disponíveis
#' @description Retorna os dados das proposições que tiveram votações nominais em plenário disponíveis
#' @param casa_aderencia informa a casa de interesse
#' @return Dataframe com os dados de proposições
fetch_proposicoes_plenario <- 
  function(casa_aderencia = "camara") {
    library(here)
    library(tidyverse)
    source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
    source(here("crawler/votacoes/fetcher_votacoes_senado.R"))
    
    if (casa_aderencia == "camara") {
      proposicoes <- map_dfr(c(2019, 2020), fetch_proposicoes_votadas_por_ano_camara) %>% mutate(id_proposicao = id)
    } else {
      proposicoes <- fetcher_votacoes_por_intervalo_senado()
      proposicoes <- proposicoes %>% mutate(nome_proposicao = map_chr(proposicoes$id_proposicao, fetch_nome_proposicoes_senado))
    }
    
    proposicoes <- proposicoes %>% 
      mutate(descricao = NA,
             titulo = NA,
             status_proposicao = "Inativa",
             status_importante = "Inativa",
             casa = casa_aderencia) %>%
      select(id_proposicao, 
             casa, 
             projeto_lei = nome_proposicao, 
             titulo, 
             descricao, 
             status_proposicao, 
             status_importante)
  }
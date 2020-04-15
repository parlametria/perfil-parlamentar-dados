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

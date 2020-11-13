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
    source(here("crawler/proposicoes/fetch_proposicoes_voz_ativa.R"))
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    
    if (casa_aderencia == "camara") {
      if (is.null(proposicoes_url)) {
        proposicoes_url <- .URL_PROPOSICOES_PLENARIO_CAMARA
      }
      proposicoes_selecionadas <- fetch_proposicoes_plenario_selecionadas(proposicoes_url)
    } else {
      if (is.null(proposicoes_url)) {
        proposicoes_url <- .URL_PROPOSICOES_PLENARIO_SENADO
      }
      proposicoes_selecionadas <- fetch_proposicoes_plenario_selecionadas_senado(proposicoes_url)
    }
    
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
    source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
    
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
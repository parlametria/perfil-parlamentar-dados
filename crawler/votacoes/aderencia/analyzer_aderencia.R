#' @title Calcula aderência para o conjunto de votos e parlamentares passados como parâmetro
#' @description A partir de informações de votos e orientações relacionadas a proposições, calcula por tema a
#' aderência de parlamentares a seus partidos e ao governo
#' @param votos_path Caminho para o arquivo de dados de votos
#' @param orientacoes_path Caminho para o arquivo de dados de orientações
#' @param parlamentares_path Caminho para o arquivo de dados de parlamentares
#' @param proposicoes_url URL para a tabela de proposições com informações dos temas no VA
#' @param casa_aderencia Casa para o cálculo da aderência (pode ser "camara" ou "senado)
#' @return Dataframe com informações de aderência
processa_aderencia_parlamentares <-
  function(votos_path = here::here("crawler/raw_data/votos.csv"),
           orientacoes_path = here::here("crawler/raw_data/orientacoes.csv"),
           parlamentares_path = here::here("crawler/raw_data/parlamentares.csv"),
           proposicoes_url = NULL,
           casa_aderencia = "camara",
           selecionadas = 1) {
    library(tidyverse)
    library(here)
    
    #TODO eliminar extras
    source(here("crawler/votacoes/utils_votacoes.R"))
    source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
    source(here("crawler/votacoes/aderencia/processa_dados_aderencia.R"))
    source(here("crawler/parlamentares/partidos/utils_partidos.R"))
    source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    source(here("crawler/proposicoes/process_proposicao_tema.R"))
    source(here("crawler/proposicoes/fetcher_proposicao_info.R"))
    
    ## Preparando dados de votos, orientações e senadores
    votos <-
      read_csv(votos_path, col_types = cols(.default = "c", voto = "i")) %>%
      filter(casa == casa_aderencia)
    
    orientacoes <-
      read_csv(orientacoes_path, col_types = cols(.default = "c", voto = "i")) %>%
      filter(casa == casa_aderencia)
    
    parlamentares <-
      read_csv(parlamentares_path, col_types = cols(id = "c")) %>%
      filter(casa == casa_aderencia, em_exercicio == 1)
    
    partidos <- parlamentares %>%
      group_by(sg_partido) %>%
      summarise(n = n()) %>%
      rowwise() %>%
      dplyr::mutate(id_partido = map_sigla_id(sg_partido)) %>%
      ungroup()
    
    proposicoes <- seleciona_proposicoes(selecionadas, casa_aderencia)
    
    if(selecionadas == 1) {
      proposicoes_temas <-
        process_proposicoes_plenario_selecionadas_temas(proposicoes_url) %>%
        filter(id_proposicao %in% (proposicoes %>% pull(id_proposicao)))
    } else {
      #TODO padronizar temas
      proposicoes_temas <- process_proposicoes_plenario_temas(proposicoes) %>%
        filter(id_proposicao %in% (proposicoes %>% pull(id_proposicao)))
    }
    
    temas <- processa_temas_proposicoes()
    
    ## Calcula aderência por tema
    aderencia_temas <-
      processa_dados_aderencia_temas(
        proposicoes_temas,
        temas,
        votos,
        orientacoes,
        parlamentares,
        filtrar = FALSE,
        casa_aderencia
      )
    
    partidos_aderencia_temas <- aderencia_temas %>%
      group_by(partido) %>%
      summarise(n = n()) %>%
      rowwise() %>%
      dplyr::mutate(id_partido = map_sigla_id(partido)) %>%
      ungroup()
    
    aderencia_temas <- aderencia_temas %>%
      left_join(partidos_aderencia_temas, by = c("partido")) %>%
      select(
        id_tema,
        id,
        nome,
        id_partido,
        faltou,
        partido_liberou,
        nao_seguiu,
        seguiu,
        total_votacoes,
        freq
      )
    
    ## Calcula aderência geral ao Partido
    aderencia_geral_partido <-
      processa_dados_deputado_aderencia(votos, orientacoes,
                                        parlamentares, filtrar = FALSE)[[2]]
    
    partidos_aderencia_geral <- aderencia_geral_partido %>%
      group_by(partido) %>%
      summarise(n = n()) %>%
      rowwise() %>%
      dplyr::mutate(id_partido = map_sigla_id(partido)) %>%
      ungroup()
    
    aderencia_geral_partido <- aderencia_geral_partido %>%
      left_join(partidos_aderencia_geral, by = c("partido")) %>%
      mutate(id_tema = 99) %>%
      select(
        id_tema,
        id,
        nome,
        id_partido,
        faltou,
        partido_liberou,
        nao_seguiu,
        seguiu,
        total_votacoes,
        freq
      )
    
    ## Calcula aderência geral ao Governo
    aderencia_geral_governo <-
      processa_dados_deputado_aderencia_governo(votos, orientacoes,
                                                parlamentares, filtrar = FALSE, casa_aderencia)[[2]] %>%
      mutate(id_partido = 0) %>%
      mutate(id_tema = 99) %>%
      select(
        id_tema,
        id,
        nome,
        id_partido,
        faltou,
        partido_liberou,
        nao_seguiu,
        seguiu,
        total_votacoes,
        freq
      )
    
    aderencia_alt <- aderencia_geral_partido %>%
      rbind(aderencia_geral_governo) %>%
      rbind(aderencia_temas) %>%
      mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa_aderencia == "camara", 1, 2),
                                         id)) %>%
      mutate(freq = if_else(freq == -1, -1, freq / 100)) %>%
      select(
        id_parlamentar_voz,
        id_partido,
        id_tema,
        faltou,
        partido_liberou,
        nao_seguiu,
        seguiu,
        aderencia = freq
      )
    
    return(aderencia_alt)
  }

seleciona_proposicoes <- 
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
    
    proposicoes
  }
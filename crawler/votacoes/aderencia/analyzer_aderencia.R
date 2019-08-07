processa_aderencia_senado <-
  function(votos_path = here::here("crawler/raw_data/votos.csv"),
           orientacoes_path = here::here("crawler/raw_data/orientacoes.csv"),
           senadores_path = here::here("crawler/raw_data/senadores.csv"),
           proposicoes_url = NULL) {
    library(tidyverse)
    library(here)
    source(here("crawler/votacoes/utils_votacoes.R"))
    source(here("crawler/votacoes/aderencia/processa_dados_aderencia.R"))
    source(here("crawler/parlamentares/partidos/utils_partidos.R"))
    source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    source(here("crawler/proposicoes/process_proposicao_tema.R"))
    
    ## Preparando dados de votos, orientações e senadores
    votos <-
      read_csv(votos_path, col_types = cols(.default = "c", voto = "i")) %>%
      filter(casa == "senado")
    
    orientacoes <-
      read_csv(orientacoes_path, col_types = cols(.default = "c", voto = "i")) %>%
      filter(casa == "senado")
    
    senadores <-
      read_csv(senadores_path, col_types = cols(id = "c")) %>%
      filter(em_exercicio == 1)
    
    partidos <- senadores %>%
      group_by(sg_partido) %>%
      summarise(n = n()) %>%
      rowwise() %>%
      dplyr::mutate(id_partido = map_sigla_id(sg_partido)) %>%
      ungroup()
    
    if (is.null(proposicoes_url)) {
      proposicoes_url = .URL_PROPOSICOES_PLENARIO_SENADO
    }
    
    ## Preparando dados de proposições e seus respectivos temas
    proposicoes <-
      fetch_proposicoes_plenario_selecionadas_senado(proposicoes_url)
    
    proposicoes <- proposicoes %>%
      filter(status_importante == "Ativa")
    
    proposicoes_temas <-
      process_proposicoes_plenario_selecionadas_temas(proposicoes_url) %>%
      filter(id_proposicao %in% (proposicoes %>% pull(id_proposicao)))
    
    temas <- processa_temas_proposicoes()
    
    ## Calcula aderência por tema
    aderencia_temas <-
      processa_dados_aderencia_temas(proposicoes_temas,
                                     temas,
                                     votos,
                                     orientacoes,
                                     senadores,
                                     filtrar = FALSE)
    
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
                                        senadores, filtrar = FALSE)[[2]]
    
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
                                                senadores, filtrar = FALSE)[[2]] %>%
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
      mutate(casa_enum = 1,
             # 1 é o código da camara. TODO: estender para senadores
             id_parlamentar_voz = paste0(casa_enum, as.character(id))) %>%
      mutate(freq = if_else(freq == -1,-1, freq / 100)) %>%
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
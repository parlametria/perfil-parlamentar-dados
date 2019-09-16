#' @title Exporta dados de proposições votadas em 2019 com temas específicos e informações de aderência nessas proposições
#' @description Exporta proposições votadas em 2019 a partir de um tema e aderência de deputados nessas votações
#' @param ano Ano de ocorrência das votações
#' @param tema Nome do tema classificado e obtido pela Câmara dos deputados (https://dadosabertos.camara.leg.br/api/v2/referencias/proposicoes/codTema)
#' @examples
#' votos <- export_aderencia_votacoes_camara_por_tema(2019, "Energia, Recursos Hídricos e Minerais|Agricultura, Pecuária, Pesca e Extrativismo")
export_aderencia_votacoes_camara_por_tema <- function(ano, tema) {
  library(tidyverse)
  source(here::here("crawler/votacoes/fetcher_votacoes_camara.R"))
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
  source(here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  source(here("crawler/votacoes/votacoes_nominais/votacoes_com_inteiro_teor/analyzer_votacoes_com_inteiro_teor.R"))
  source(here("crawler/votacoes/orientacoes/fetcher_orientacoes_camara.R"))
  source(here("crawler/votacoes/aderencia/processa_dados_aderencia.R"))
  
  ano = 2019
  
  votacoes <-
    fetch_all_votacoes_por_intervalo_camara(ano, ano)
  
  proposicoes_votadas_detalhadas <-
    purrr::map_df(votacoes$id_proposicao %>% unique(),
                  ~ fetch_info_proposicao(.x))
  
  proposicoes_votadas_filtradas <- proposicoes_votadas_detalhadas %>% 
    filter(str_detect(tema, "Energia, Recursos Hídricos e Minerais|Agricultura, Pecuária, Pesca e Extrativismo"))
  
  write_csv(proposicoes_votadas_filtradas, here("crawler/raw_data/proposicoes_agricultura_energia_minerais.csv"))
  
  ## Calculando Aderência
  
  ### Recuperando Votos
  proposicoes_votadas <- tryCatch({
    fetch_proposicoes_votadas_por_ano_camara(ano)
  }, error = function(e) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  })
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  votos <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_votos_por_ano_camara, 
      ano
    )) %>% 
    unnest(dados) %>% 
    mutate(partido = padroniza_sigla(partido)) %>% 
    distinct() 
  
  votos_filtrados <- votos %>% 
    filter(id_proposicao %in% (proposicoes_votadas_filtradas %>% pull(id))) %>% 
    mutate(ano = "2019",
           casa = "camara") %>% 
    select(ano, id_proposicao, id_votacao, id_parlamentar = id_deputado, voto, partido, casa)
  
  ### Recuperando orientações
  
  orientacao <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_orientacoes_por_proposicao_camara, 
      ano
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  orientacao_filtrada <- orientacao %>% 
    filter(id_proposicao %in% (proposicoes_votadas_filtradas %>% pull(id))) %>% 
    mutate(ano = "2019",
           casa = "camara") %>% 
    select(ano, id_proposicao, id_votacao, partido, voto, casa)
  
  ### Realizando cálculo da aderência
  deputados <-
    read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>%
    filter(casa == "camara", em_exercicio == 1)
  
  aderencia_geral_governo <-
    processa_dados_deputado_aderencia_governo(votos_filtrados, orientacao_filtrada,
                                              deputados, filtrar = FALSE, "camara")[[2]] %>%
    mutate(orientacao = "Governo") %>% 
    mutate(aderencia = if_else(freq == -1, NA_real_, freq)) %>% 
    select(id, faltou, partido_liberou, nao_seguiu, seguiu, total_votacoes, aderencia)
  
  deputados_aderencia <- deputados %>% 
    select(id, nome_eleitoral, sg_partido, uf) %>% 
    left_join(aderencia_geral_governo, by = "id")
  
  write_csv(deputados_aderencia, here("crawler/raw_data/parlamentares_aderencia_agricultura_energia_minerais.csv"))
}

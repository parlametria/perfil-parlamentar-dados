#' @title Processa orientação de proposições votadas em plenário para um determinado ano
#' @description Recupera informação das orientações dos partidos para um determinado ano
#' @param ano Ano para ocorrência das votações em plenário
#' @param url Link para dados das proposições selecionadas para captura das votações em plenário
#' Se url é diferente de NULL, então considerará lista de proposições presentes nos dados disponíveis através da URL
#' @return Dataframe com informações das orientações
#' @examples
#' orientacao <- process_orientacao_por_ano(2019)
process_orientacao_por_ano_camara <- function(ano = 2019, url = NULL) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/orientacoes/fetcher_orientacoes_camara.R"))
  source(here("crawler/votacoes/fetcher_votacoes_camara.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  proposicoes_votadas <- tryCatch({
    fetch_proposicoes_votadas_por_ano_camara(ano)
  }, error = function(e) {
    data <- tribble(~ id, ~ nome_proposicao, ~ data_votacao)
    return(data)
  })
  
  if (!is.null(url)) {
    proposicoes_selecionadas <- read_csv(url, col_types = cols(id = "c")) %>% 
      filter(tolower(tema_va) != "não entra") %>% 
      select(id, nome_proposicao = nome)
    
    proposicoes_votadas <- proposicoes_votadas %>% 
      filter(id %in% (proposicoes_selecionadas %>% pull(id)))
  }
  
  ## checa se existem proposições com dados de votações em plenário para aquele ano
  if (nrow(proposicoes_votadas) == 0) {
    data <- tribble(~ id_proposicao, ~ id_votacao, ~ partido, ~ voto)
    return(data)
  }
  
  proposicoes <- proposicoes_votadas %>% 
    distinct(id, nome_proposicao)
  
  orientacao <- tibble(id_proposicao = proposicoes$id) %>%
    mutate(dados = map(
      id_proposicao,
      fetch_orientacoes_por_proposicao_camara, 
      ano
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(orientacao)
}

#' @title Processa orientação de proposições (selecionadas pela equipe VA) votadas em plenário para um conjunto de anos
#' @description Recupera informação das orientações dos partidos para um conjunto de anos para as 
#' proposicoes selecionadas pela equipe VA.
#' @param anos Vector com lista de anos
#' @return Lista contendo orientações
#' @examples
#' orientacao <- process_orientacao_anos_url_camara(2019)
process_orientacao_anos_url_camara <- function(anos = c(2019, 2020, 2021, 2022),
                                               url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSvvT0fmGUMwOHnEPe9hcAMC_l-u9d7sSplNYkMMzgiE_vFiDcWXWwl4Ys7qaXuWwx4VcPtFLBbMdBd/pub?gid=399933255&single=true&output=csv") {
  library(tidyverse)
  
  orientacao <- tibble(ano = anos) %>%
    mutate(dados = map(
      ano,
      process_orientacao_por_ano_camara,
      url
    )) %>% 
    unnest(dados) %>% 
    distinct()
  
  return(orientacao)
}

#' @title Processa orientação dos votos de plenário para um conjunto de votações
#' @description Recupera informação das orientações dos partidos para um conjunto de votações
#' @param votos_datapath Caminho para o dataframe contendo dados de votações
#' @return Lista contendo orientações
#' @examples
#' orientacao <- process_orientacao_senado()
process_orientacao_senado <- function(votos_datapath = NULL) {
  library(tidyverse)
  
  if(is.null(votos_datapath)){
    source(here::here("crawler/votacoes/votos/analyzer_votos.R"))
    votos <- process_votos_por_votacoes_senado()
    
  } else {
    votos <- read_csv(votos_datapath)
  }
  
  orientacoes_governo <- define_orientacao_governo(votos)
  
  partidos <- votos %>% 
    select(partido) %>% 
    distinct() %>% 
    filter(partido != "SPARTIDO")
  
  orientacoes_governo <- orientacoes_governo %>% 
    bind_rows(purrr::map_df(partidos$partido, ~ calcula_voto_maioria_absoluta(votos, .x)) %>% 
            mutate(casa = 'senado')) %>% 
    select(ano, id_proposicao, id_votacao, partido, voto)
  
  return(orientacoes_governo)
  
}

#' @title Define a orientação de um partido para um conjunto de votos
#' @description Recupera informação das orientações dos partidos para um conjunto de votos utilizando a maioria absoluta.
#' No caso de empate entre os votos, o voto será o do líder do partido.
#' @param votos Dataframe contendo dados de votos
#' @param sigla_partido Sigla do partido a ter orientações recuperadas
#' @return Dataframe contendo informações de orientações de um partido
#' @examples
#' orientacao <- calcula_voto_maioria_absoluta(votos, "PSL")
calcula_voto_maioria_absoluta <- function(votos, sigla_partido) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/liderancas/fetcher_liderancas_senado.R"))
  
  print(paste0("Calculando orientação do partido ", sigla_partido))
  
  orientacoes <- votos %>% 
    group_by(ano, id_proposicao, id_votacao, partido, voto) %>% 
    filter(partido == sigla_partido | (sigla_partido == "Governo" & partido == "PSL")) %>% 
    count() %>% 
    ungroup() %>% 
    group_by(id_votacao) %>% 
    filter(n == max(n)) %>% 
    mutate(empate = if_else(n() > 1, 1, 0)) %>% 
    distinct() %>% 
    select(-n)
  
  lider <- fetch_liderancas_senado() %>% 
    filter(bloco_partido == sigla_partido & cargo == "Líder")
  
  votos <- votos %>% 
    rename(id_votacao_votos = id_votacao)
  
  if(nrow(orientacoes %>% filter(empate == 1)) > 0) {
    
    orientacoes <- orientacoes %>% 
      mutate(voto =
               if_else(
                 empate == 1,
                 votos %>%
                   filter(id_parlamentar == lider$id &
                            id_votacao_votos == id_votacao) %>%
                   pull(voto),
                 voto
               ))
  }
  
  orientacoes <- orientacoes %>%
    select(-empate)

  return(orientacoes)
}

#' @title Define a orientação do Governo
#' @description Recupera informação das orientações do Governo com base nos votos do Líder
#' @param votos Dataframe contendo dados de votos
#' @return Dataframe contendo informações de orientações do Governo
#' @examples
#' orientacao <- define_orientacao_governo(votos)
define_orientacao_governo <- function(votos) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/liderancas/fetcher_liderancas_senado.R"))
  
  lideres <- fetch_liderancas_senado() %>% 
    filter(bloco_partido == "Governo")
  
  orientacoes <- votos %>% 
    filter(id_parlamentar == lideres %>% 
             filter(cargo == "Líder") %>% 
             pull(id)) %>% 
    select(-id_parlamentar)
  
  return(orientacoes)
  
}

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
  source(here("crawler/votacoes/fetcher_votacoes.R"))
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

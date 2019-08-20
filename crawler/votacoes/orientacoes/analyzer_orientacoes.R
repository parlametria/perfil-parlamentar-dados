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
                                               url = NULL) {
  library(tidyverse)
  library(here)
  
  if(is.null(url)) {
    source(here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_CAMARA
  }

  orientacao <- tibble(ano = anos) %>%
    mutate(dados = map(
      ano,
      process_orientacao_por_ano_camara,
      url
    )) %>% 
    unnest(dados) %>% 
    distinct() %>% 
    mutate(casa = "camara")
  
  return(orientacao)
}

#' @title Processa orientação dos votos de plenário para um conjunto de votações
#' @description Recupera informação das orientações dos partidos para um conjunto de votações
#' @param votos_datapath Caminho para o dataframe contendo dados de votações
#' @return Lista contendo orientações
#' @examples
#' orientacao <- process_orientacao_senado()
process_orientacao_senado <- function(votos_datapath = here::here("crawler/raw_data/votos.csv")) {
  library(tidyverse)
  
  votos <- read_csv(votos_datapath) %>% 
      filter(casa == "senado")

  orientacoes_governo <- define_orientacao_governo(votos)
  
  partidos <- votos %>% 
    select(partido) %>% 
    distinct() %>% 
    filter(partido != "SPARTIDO")
  
  orientacoes_partido <- 
    purrr::map_df(partidos$partido, ~ calcula_voto_maioria_absoluta(votos, .x))
  
  orientacoes <- orientacoes_governo %>% 
    bind_rows(orientacoes_partido) %>% 
    distinct(id_votacao, partido, .keep_all = TRUE) %>% 
    select(ano, id_proposicao, id_votacao, partido, voto, casa)
    
  
  return(orientacoes)
  
}

#' @title Define a orientação de um partido para um conjunto de votos
#' @description Recupera informação das orientações dos partidos para um conjunto de votos utilizando a maioria absoluta.
#' No caso de empate entre os votos, o voto será o do líder do partido.
#' @param votos Dataframe contendo dados de votos
#' @param sigla_partido Sigla do partido a ter orientações recuperadas
#' @return Dataframe contendo informações de orientações de um partido
get_voto_lider <- function(lideres, votos, id_votacao) {
  library(tidyverse)
  
  if(nrow(lideres) > 0) {
    voto <- (lideres$id %>% 
               purrr::map(function(x) {
                 data <- votos %>%
                   filter(id_parlamentar == x &
                            id_votacao_votos %in% id_votacao) %>%
                   pull(voto)
               }))[[1]]
  } else {
    voto <- (votos %>% 
      filter(id_votacao_votos %in% id_votacao) %>% 
      group_by(voto) %>% 
      mutate(maioria = n(),
             voto_final = max(maioria)) %>% 
      arrange(desc(voto_final)) %>% 
      pull(voto))[[1]]
  }

   if(length(voto) == 0) {
     return(0)
   } else{
     return(voto)
   }
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
    group_by(ano, id_proposicao, id_votacao, partido, voto, casa) %>% 
    filter(partido == sigla_partido) %>% 
    count() %>% 
    ungroup() %>% 
    group_by(id_votacao) %>% 
    filter(n == max(n)) %>% 
    mutate(empate = if_else(n() > 1, 1, 0)) %>% 
    distinct() %>% 
    select(-n)
  
  lideres <- fetch_liderancas_senado() %>% 
    filter(bloco_partido == sigla_partido)
  
  votos <- votos %>% 
    rename(id_votacao_votos = id_votacao)
  
  if(nrow(orientacoes %>% filter(empate == 1)) > 0) {
    orientacoes <- orientacoes %>% 
      mutate(voto = if_else(empate == 1,
                            get_voto_lider(lideres, votos, id_votacao),
                            voto)) %>% 
      unique()
  }
  
  orientacoes <- orientacoes %>%
    select(-empate) %>% 
    ungroup()

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
    mutate(partido = "Governo",
           voto = if_else(voto == 0, 5, as.numeric(voto))) %>% 
    select(-id_parlamentar, ano, id_proposicao, id_votacao, partido, voto, casa)
  
  return(orientacoes)
  
}

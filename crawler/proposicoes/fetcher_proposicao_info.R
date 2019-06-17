#' @title Recupera informações dos temas de uma proposição
#' @description A partir do id, recupera dados de uma proposição na Câmara dos Deputados,
#' como nome e tema
#' @param id_prop ID de uma proposição
#' @return Dataframe contendo informações de uma proposição
#' @examples
#' proposicao <- fetch_tema_proposicao(2193540)
fetch_tema_proposicao <- function(id_prop) {
  library(tidyverse)
  library(rcongresso)
  
  print(paste0("Baixando informações da proposição ", id_prop))
  
  temas  <- tryCatch({
    url <-
      paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
             id_prop,
             "/temas")
    data <- (RCurl::getURI(url) %>%
               jsonlite::fromJSON())$dados %>%
      as.data.frame() %>%
      select(tema)
    
  }, error = function(e) {
    return(dplyr::tribble(~ tema))
  })
  
  proposicao <- rcongresso::fetch_proposicao_camara(id_prop) %>%
    mutate(
      nome = paste0(siglaTipo, " ", numero, "/", ano),
      data_apresentacao = lubridate::ymd_hm(gsub("T", " ", dataApresentacao)) %>%
        format("%d/%m/%Y"),
      id = as.character(id),
      tema = paste(unlist(temas$tema), collapse = '; ')
    ) %>%
    select(id, nome, data_apresentacao, tema)
  
  return(proposicao)
}

#' @title Mapeia conjunto de temas da câmara para uma proposição para um tema do Voz Ativa
#' @description A partir de ums string com temas da câmara mapeia para um tema do Voz Ativa
#' @param tema_camara String com lista dos temas da Câmara separados por ;
#' @return String com o tema do voz ativa mapeado
#' @examples
#' temaVA <- map_tema_camara_tema_va("Meio Ambiente e Desenvolvimento Sustentável")
map_tema_camara_tema_va <- function(tema_camara) {
  library(tidyverse)
  
  tema_voz <- case_when(
    str_detect(tema_camara, "Meio Ambiente e Desenvolvimento Sustentável") ~ "Meio Ambiente",
    str_detect(tema_camara, "Energia, Recursos Hídricos e Minerais") ~ "Meio Ambiente",
    str_detect(tema_camara, "Agricultura, Pecuária, Pesca e Extrativismo") ~ "Meio Ambiente",
    str_detect(tema_camara, "Direitos Humanos e Minorias") ~ "Direitos Humanos",
    str_detect(tema_camara, "Educação") ~ "Educação",
    TRUE ~ "INDEFINIDO"
  )
  
  return(tema_voz)
}

#' @title Recupera informações dos temas para todas as proposições votadas em plenário na legislatura 56
#' @description Classifica por tema e lista proposições votadas em plenário na legislatura 56
#' @return Dataframe com lista de proposições e seus respectivos temas
#' @examples
#' proposicoes_temas <- fetch_votacoes_plenario_tema()
fetch_votacoes_plenario_tema <- function() {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/fetcher_votacoes.R"))
  
  proposicoes_votadas <-
    purrr::map_df(
      c(2019, 2020, 2021, 2022),
      fetch_votacoes_ano
    ) %>% 
    distinct(id, nome_proposicao)
  
  proposicoes_temas <- 
    purrr::map_df(
      proposicoes_votadas$id,
      fetch_tema_proposicao
    )
    
  proposicoes_temas_va <- proposicoes_temas %>% 
    mutate(tema_vozativa = map_tema_camara_tema_va(tema))
  
}

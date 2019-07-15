#' @title Recupera informações dos temas das proposições de um ano
#' @description A partir do ano, recupera todos os temas das proposições
#' @param ano Ano
#' @return Dataframe contendo informações dos temas das proposições por ano
#' @examples
#' propositions_temas <- fetch_tema_proposicoes(2019)
fetch_tema_proposicoes <- function(ano = 2019) {
  library(tidyverse)
  
  url <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/csv/proposicoesTemas-", ano, ".csv")
  temas <-readr::read_delim(url, delim = ";")
    
  temas <- temas %>% 
    mutate(id = stringr::str_extract(uriProposicao, '\\d*$') %>% as.numeric()) %>% 
    group_by(id) %>% 
    summarise(tema = paste(unlist(tema), collapse = '; '))
  
  return(temas)
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

#' @title Recupera informações dos temas para todas as proposições criadas na legislatura 56
#' @description Classifica por tema e lista proposições criadas na legislatura 56
#' @return Dataframe com lista de proposições e seus respectivos temas
#' @examples
#' proposicoes_temas <- fetch_propositions()
fetch_propositions <- function(initial_date = "2019-02-01") {
  library(tidyverse)
  
  url <-
    "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv"
  
  propositions <- readr::read_delim(url, delim = ";") %>%
    filter(dataApresentacao >= initial_date) %>%
    select(id, siglaTipo, numero, ano)
  
  ano = strsplit(initial_date, '-')[[1]][1]
  propositions_themes <- fetch_tema_proposicoes(ano)
  
  propositions_ma <- propositions_themes %>%  
    mutate(tema_vozativa = map_tema_camara_tema_va(tema)) %>% 
    filter(tema_vozativa == 'Meio Ambiente') %>% 
    select(-tema, -tema_vozativa) %>% 
    unique() %>% 
    inner_join(propositions, by = "id")
  
  return(propositions_ma)
}

fetch_relacionadas <- function(id_prop, ano_prop) {
  print(paste0("Baixando proposições relacionadas a ", id_prop, "..."))
  url <-
    paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/",
           id_prop,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>% 
    filter(ano == ano_prop)
  
  if (nrow(ids_relacionadas) == 0) {
    return(tribble(~ id, id_prop))
  } 
  
  return (ids_relacionadas %>% 
    select(id) %>% 
    rbind(id_prop))
  
  return(ids_relacionadas)
}

fetch_all_relacionadas <- function(ids, anos) {
  relacionadas <- purrr::map2_df(ids, anos, ~ fetch_relacionadas(.x, .y)) %>% 
    dplyr::distinct()
  
  return(relacionadas)
}

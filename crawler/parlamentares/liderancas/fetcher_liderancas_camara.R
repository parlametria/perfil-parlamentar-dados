#' @title Recupera as informações sobre lideranças de blocos e partidos
#' @description Retorna um dataframe contendo os líderes, vice-líderes e representantes dos blocos e partidos na Câmara
#' @return Dataframe contendo lideranças dos blocos e partidos na Câmara
#' @examples
#' liderancas <- fetch_liderancas_camara()
fetch_liderancas_camara <- function() {
  library(tidyverse)
  url <-
    "https://www.camara.leg.br/SitCamaraWS/Deputados.asmx/ObterLideresBancadas"
  
  xml <- RCurl::getURL(url) %>%
    xml2::read_xml() %>%
    xml2::as_list()
  
  xml <- xml[[1]]
  
  data <- purrr::map_df(xml, function(x) {
    partido_lideranca <- attributes(x)$sigla
    
    if (!is.null(x$lider)) {
      df <- x$lider %>%
        t() %>%
        as_data_frame() %>%
        unnest() %>%
        mutate(cargo = "Líder") %>%
        rename(id = ideCadastro) %>% 
        unnest()
      
      if (!is.null(x$vice_lider)) {
        vices <- x %>%
          t()
        
        # Resolve problema de dois objetos dentro de uma única tag
        vices <- purrr::map_df(vices, function(y) {
          if (length(y) > 4) {
            return(y[1:5])
          }
          return(y)
        })
        
        vices <- vices %>%
          unnest() %>%
          mutate(cargo = "Vice-líder") %>% 
          rename(id = ideCadastro)
        
        df <- bind_rows(df, vices)
        
      }
      
      df <- df %>%
        mutate(bloco_partido = partido_lideranca) %>%
        select(bloco_partido, id, nome, cargo, partido, uf)
      
    } 
    else {
      df <- x$representante %>%
        t() %>%
        as_data_frame() %>%
        unnest() %>%
        mutate(cargo = "Representante",
               bloco_partido = partido_lideranca) %>%
        select(bloco_partido, id = ideCadastro, nome, cargo, partido, uf) %>% 
        unnest()
    }
    
    return(df)
  }) %>%
    mutate(casa = "camara")
  
  return(data)
}

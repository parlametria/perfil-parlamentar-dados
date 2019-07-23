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
    partido_lideranca <- attr(x, "sigla")
    
    if (!is.null(x$lider)) {
      df <- x$lider %>%
        t() %>%
        as_data_frame() %>%
        unnest() %>%
        mutate(cargo = "Líder") %>%
        rename(id = ideCadastro)
      
      if (!is.null(x$vice_lider)) {
        vices <- x %>%
          t() %>%
          as_tibble() %>%
          unnest() %>%
          t() %>%
          as_tibble() %>%
          unnest()
        
        vices <- vices %>%
          slice(2:nrow(vices)) %>%
          rename(
            nome = V1,
            id = V2,
            partido = V3,
            uf = V4
          ) %>%
          mutate(cargo = "Vice-líder")
        
        df <- bind_rows(df, vices)
        
      }
      
      df <- df %>%
        mutate(bloco_partido = partido_lideranca) %>%
        select(bloco_partido, id, nome, cargo, partido, uf)
      
    } else {
      df <- x$representante %>%
        t() %>%
        as_data_frame() %>%
        unnest() %>%
        mutate(cargo = "Representante",
               bloco_partido = partido_lideranca) %>%
        select(bloco_partido, id = ideCadastro, nome, cargo, partido, uf)
    }
    
    return(df)
  }) %>%
    unnest() %>% 
    mutate(casa = "camara")
  
  return(data)
}

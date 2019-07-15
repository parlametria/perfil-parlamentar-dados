#' @title Extrai informações sobre as votações nas comissões de um parlamentar em um ano
#' @description Recebe um id e o ano e retorna um dataframe contendo informações de votações de comissões, como id_proposicao,
#' objeto_votacao, id_parlamentar, comissao, link_votacao, data, hora e voto.
#' @param id id do parlamentar
#' @param ano ano das votações
#' @return Dataframe contendo informações de votações de comissões, como id_proposicao,
#' objeto_votacao, id_parlamentar, comissao, link_votacao, data, hora e voto.
#' @examples
#' fetch_votacoes_deputado(177282, 2019)
fetch_votacoes_deputado <- function(id, ano) {
  library(tidyverse)
  library(rvest)
  
  print(paste0("Baixando votações nas comissões do deputado de id ", id))
  
  url <-
    paste0("https://www.camara.leg.br/deputados/",
           id,
           "/votacoes-comissoes?ano=",
           ano)
  
  data <-
    xml2::read_html(url) %>%
    html_nodes(xpath = './/table') %>%
    map_df(function(x) {
      y = x %>% html_nodes('tr')
      
      map_df(y[3:length(y)], function(y) {
        gsub('\n', '',
             y %>% html_nodes('td') %>%
               html_text() %>% t()) %>%
          as.data.frame(stringsAsFactors = FALSE) %>%
          select(objeto_votacao = V2,
                 voto = V3) %>%
          mutate(
            id_proposicao =
              html_nodes(y, 'a') %>%
              html_attr('href') %>%
              stringr::str_extract('[\\d]*$')
          )
      }) %>%
        mutate(
          comissao = html_nodes(x, 'th')[[1]] %>%
            html_text(),
          link_votacao = html_nodes(x, 'th') %>%
            html_nodes('a') %>%
            html_attr('href'),
          data = stringr::str_extract(comissao, '\\d{2}/\\d{2}/\\d{4}'),
          hora = stringr::str_extract(comissao, '\\d{2}:\\d{2}'),
          id_parlamentar = id,
          comissao = comissao %>% stringr::str_remove(' -.*'),
          voto = if_else(voto == 'Favorável', 1, -1)
        ) %>%
        select(
          id_proposicao,
          objeto_votacao, 
          id_parlamentar, 
          comissao, 
          link_votacao, 
          data, 
          hora,
          voto
        )
    })
  
  return(data)
}

#' @title Extrai informações sobre as votações nas comissões de todos os parlamentares em um ano
#' @description Recebe um dataframe contendo id e o ano e retorna um dataframe contendo informações de votações de comissões, como id_proposicao,
#' objeto_votacao, id_parlamentar, comissao, link_votacao, data, hora e voto.
#' @param parlamentares_datapath dataframe com informações de id dos parlamentares
#' @return Dataframe contendo informações de votações de comissões, como id_proposicao,
#' objeto_votacao, id_parlamentar, comissao, link_votacao, data, hora e voto.
#' @examples
#' fetch_all_votacoes_por_ano()
fetch_all_votacoes_por_ano <-
  function(parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
           ano = 2019) {
    library(tidyverse)
    
    ids_parlamentares <- (readr::read_csv(parlamentares_datapath) %>%
                            filter(situacao == 'Exercício'))$id
    
    votacoes <-
      purrr::map_df(ids_parlamentares, ~ fetch_votacoes_deputado(.x, ano))
  }

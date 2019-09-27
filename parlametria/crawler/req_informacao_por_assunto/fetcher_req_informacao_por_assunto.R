#' @title Retorna os autores de requerimentos de informação sobre um determinado assunto (em formato regex)
#' @description Recebe uma URL para um arquivo csv de proposições e um termo do assunto a ser filtrado 
#' (em formato de expressão regular) e retorna os autores que fizeram os requerimentos de informação sobre o assunto.
#' @param url_proposicoes URL do arquivo csv das proposições
#' @param term Termo da busca (regex)
#' @return Dataframe dos autores que fizeram os requerimentos de informação sobre o assunto.
#' @examples
#' fetch_req_informacao_autores(term = 'agricultura|meio ambiente')
fetch_req_informacao_autores <- function(
  url_proposicoes = "https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2019.csv",
  term) {
  library(tidyverse)
  
  source(here::here("crawler/parlamentares/coautorias/fetcher_authors.R"))
  
  proposicoes_ric <- read_delim(url_proposicoes, ";") %>% 
    filter(siglaTipo == "RIC") %>% 
    select(id, ementa, urlInteiroTeor)
  
  proposicoes <- 
    filter_proposicoes_inteiro_teor_and_ementa_by_term(proposicoes_ric,
                                                       term)
  parlamentares <- read_csv(here::here("crawler/raw_data/parlamentares.csv"))
  
  autores <- fetch_all_autores(proposicoes) %>% 
    select(-peso_arestas)
  
  autores <- autores %>% 
    group_by(id) %>% 
    summarise(num_req_informacao = n())
  
  return(autores)
}

#' @title Filtra as proposições por termo
#' @description Recebe um conjunto de proposições e filtra a ementa e inteiro teor pelo termo parametrizado
#' @param proposicoes Dataframe com as proposições, contendo pelo menos id, ementa e urlInteiroTeor
#' @param term Termo do filtro (regex)
#' @return Id das proposições filtradas
filter_proposicoes_inteiro_teor_and_ementa_by_term <- function(proposicoes, term) {
  library(tidyverse)

  proposicoes_com_inteiro_teor <-
    map2_df(
      proposicoes$id,
      proposicoes$urlInteiroTeor,
      function(x, y) {
        source(here::here("crawler/utils/utils.R"))
        
        text <- extract_text_from_pdf_url(y)
        df <- tryCatch({
          return(data.frame(id = x, texto_inteiro_teor = text))
          
        }, error = function(e) {
          return(tribble(~ id, ~ texto_inteiro_teor))
        })
        return(df)
      })
  
  id_proposicoes_filtered <- proposicoes %>%
    filter(str_detect(tolower(ementa), term)) %>%
    select(id) %>%
    rbind(proposicoes_com_inteiro_teor %>%
            filter(str_detect(tolower(texto_inteiro_teor), term)) %>%
            select(id)) %>% 
    distinct()
  
  return(id_proposicoes_filtered)
}

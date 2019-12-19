fetch_votacoes <- function(anos = c(2019, 2015, 2011, 2007, 2003, 1999)) {
  library(tidyverse)
  library(here)
  library(purrr)
  
  source(here("crawler/votacoes/fetcher_votacoes_senado.R"))
  source(here("crawler/proposicoes/fetcher_proposicoes_senado.R"))
  
  votacoes <- map_df(anos, function(x) {
    print(paste0("Baixando votações de ", x))
    data_inicial <- paste0("01/02/", x)
    data_final <- if_else(x == "2019", format(Sys.Date(), "%d/%m/%Y"), paste0("31/12/", x))
    votacoes_ano <- fetcher_votacoes_por_intervalo_senado(data_inicial, data_final) %>% 
      mutate(ano = x)
    return(votacoes_ano)
  })
  
  
  proposicoes_votadas <- map_df(votacoes$id_proposicao, ~ fetch_proposicoes_senado(.x))
  
  return(list(votacoes, proposicoes_votadas))
}

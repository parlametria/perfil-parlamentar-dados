library(tidyverse)
library(here)

#' @title Processa Investimento Partidário
#' @description Recupera o investimento partidário em parlamentares durante a campanha eleitoral
#' @return Dataframe contendo lista de parlamentares e o investimento partidário
process_investimento_partidario <- function() {
  investimento_partidario <- read_csv(here("parlametria/raw_data/resumo/parlamentares_investimento.csv"),
                                      col_types = cols(id = "c")) %>% 
    filter(sg_partido == partido_eleicao,
           em_exercicio == 1) %>% 
    select(id, casa, investimento_partidario = proporcao_campanhas_medias_receita) %>% 
    distinct() %>% 
    mutate(
      investimento_partidario = sqrt(investimento_partidario)/sqrt(max(investimento_partidario)))
  
  return(investimento_partidario)
}

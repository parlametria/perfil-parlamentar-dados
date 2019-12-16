#' @title Filtra os votos de deputados selecionados na Reforma da Previdência 
#' @description Recebe uma url contendo coluna id dos deputados selecionados e um caminho para o dataframe de parlamentares,
#' baixa os votos da votaçao do texto final da PEC 6/2019 (Reforma da Previdência) e retorna os votos dos parlamentares selecionados.
#' @param url_planilha_deputados_selecionados URL para planinha contendo coluna id com os deputados selecionados
#' @param parlamentares_datapath Caminho para o arquivo csv dos parlamentares.
#' @return Dataframe com os votos dos parlamentares selecionados.
#' @examples
#' votos_pec_6_2019 <- filter_votos_pec_6_2019()
filter_votos_pec_6_2019 <- function(
  url_planilha_deputados_selecionados = "https://docs.google.com/spreadsheets/d/e/2PACX-1vShw-2Or9QH4WzRagrBxvWC9eqBRCiYaKkgV7YUlExxb8spHNW6k-VCeDmnv1peK7caIVdyBuW6V_kG/pub?gid=0&single=true&output=csv",
  parlamentares_datapath = here::here("reports/atuacao-deputados-milionarios/data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  deputados_selecionados <- read_csv(url_planilha_deputados_selecionados, col_types = cols(.default = "c")) %>% 
    distinct(id) %>% 
    pull(id)
  
  proposicao <- 2192459
  votacao <- 168870012
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(.default = "c"))
  
  votos <- fetch_votos_por_ano_camara(proposicao, ano = 2019) 
  
  votos_filtrados <- votos %>% 
    filter(id_deputado %in% deputados_selecionados, id_votacao == votacao)
  
  votos_deputados <- votos_filtrados %>% 
    inner_join(parlamentares, by = c("id_deputado"="id")) %>% 
    select(id = id_deputado, nome_eleitoral, sg_partido, uf, voto) %>% 
    nomeia_voto_camara()
  
  return(votos_deputados)
}

#' @title Processa dados de receitas dos parlamentares
#' @description A partir de um csv das receitas dos parlamentares processa e sumariza os dados
#' @param datapath Caminho para os dados de receitas
#' @return Dataframe
#' @examples
#' doacoes <- processa_doacoes_partidarias_tse()
processa_doacoes_partidarias_tse <- function(datapath = 
                                               here::here("crawler/parlamentares/receitas/receitas_candidatos_2018_BRASIL.csv")) {
  library(tidyverse)
  
  receitas <- read_delim(datapath, delim = ";", col_types = cols(SQ_CANDIDATO = "c", VR_RECEITA = "c"),
                         locale = locale(encoding = 'latin1')) %>% 
    select(DS_CARGO, SG_UE, SQ_CANDIDATO, NM_CANDIDATO, NR_CPF_CANDIDATO, SG_PARTIDO, DS_FONTE_RECEITA, DS_ORIGEM_RECEITA,
           NM_DOADOR, NM_DOADOR_RFB, VR_RECEITA) %>% 
    mutate(VR_RECEITA = as.numeric(gsub(",", ".", VR_RECEITA)))
  
  receitas_filtradas <- receitas %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador")) %>% 
    filter(trimws(DS_ORIGEM_RECEITA, which = "both") == "Recursos de partido político")
  
  receitas_group <- receitas_filtradas %>% 
    mutate(id_tse = SQ_CANDIDATO) %>% 
    group_by(id_tse) %>% 
    summarise(
      cargo = first(DS_CARGO),
      uf = first(SG_UE),
      partido = first(SG_PARTIDO),
      nome = first(NM_CANDIDATO),
      cpf = first(NR_CPF_CANDIDATO),
      total_receita = sum(VR_RECEITA))
  
  return(receitas_group)
}

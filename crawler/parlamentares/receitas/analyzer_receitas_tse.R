#' @title Processa dados de receitas dos parlamentares
#' @description A partir de um csv das receitas dos parlamentares processa e sumariza os dados
#' @param datapath Caminho para os dados de receitas
#' @return Dataframe
#' @examples
#' doacoes <- processa_doacoes_partidarias_tse()
processa_doacoes_partidarias_tse <- 
  function(receitas_datapath = here::here("crawler/parlamentares/receitas/receitas_candidatos_2018_BRASIL.csv"),
           candidatos_datapath = here::here("crawler/parlamentares/receitas/consulta_cand_2018_BRASIL.csv")) {
    
  library(tidyverse)
    
  candidatos <- read_delim(candidatos_datapath, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                           locale = locale(encoding = 'latin1')) %>% 
    filter(DS_SITUACAO_CANDIDATURA == "APTO") %>% 
    filter(DS_DETALHE_SITUACAO_CAND %in% c("DEFERIDO", "DEFERIDO COM RECURSO")) %>% 
    select(DS_CARGO, SG_UE, SQ_CANDIDATO, NM_CANDIDATO, NR_CPF_CANDIDATO, SG_PARTIDO) %>% 
    mutate(DS_CARGO = str_to_title(DS_CARGO)) %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador"))
    
  receitas <- read_delim(receitas_datapath, delim = ";", col_types = cols(SQ_CANDIDATO = "c", VR_RECEITA = "c"),
                         locale = locale(encoding = 'latin1')) %>% 
    select(DS_CARGO, SG_UE, SQ_CANDIDATO, NM_CANDIDATO, NR_CPF_CANDIDATO, SG_PARTIDO, 
           DS_FONTE_RECEITA, DS_ORIGEM_RECEITA, NM_DOADOR, NM_DOADOR_RFB, VR_RECEITA) %>% 
    mutate(VR_RECEITA = as.numeric(gsub(",", ".", VR_RECEITA)))
  
  receitas_filtradas <- receitas %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador")) %>% 
    filter(trimws(DS_ORIGEM_RECEITA, which = "both") == "Recursos de partido político")
  
  receitas_group <- receitas_filtradas %>% 
    group_by(SQ_CANDIDATO) %>% 
    summarise(total_receita = sum(VR_RECEITA))
  
  candidatos_receita <- candidatos %>% 
    left_join(receitas_group, by = c("SQ_CANDIDATO")) %>% 
    mutate(total_receita = if_else(is.na(total_receita), 0, total_receita)) %>% 
    select(id_tse = SQ_CANDIDATO, cargo = DS_CARGO, uf = SG_UE, partido = SG_PARTIDO, nome = NM_CANDIDATO,
           cpf = NR_CPF_CANDIDATO, total_receita)
  
  return(candidatos_receita)
}

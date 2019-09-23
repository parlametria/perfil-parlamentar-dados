#' @title Processa dados de receitas dos parlamentares
#' @description A partir de um csv das receitas dos parlamentares processa e sumariza os dados
#' @param datapath Caminho para os dados de receitas
#' @param candidatos_datapath Caminho para os dados de candidatos nas eleições de 2018
#' @return Dataframe
#' @examples
#' doacoes <- processa_doacoes_partidarias_tse()
#' 
#' Observações 
#' 1. Consideramos apenas doações nas quais a origem de Receita é proveniente de Recursos de partido político
#' 2. Os candidatos que situação de candidatura APTO e DEFERIDO (com recurso ou não) são considerados. 
#' Atribuímos 0 se não existirem receitas mas o candidato ainda participou da eleição
#' 3. Consideramos apenas as doações do mesmo partido do candidato na eleição.
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
           DS_FONTE_RECEITA, DS_ORIGEM_RECEITA, NM_DOADOR, NM_DOADOR_RFB, SG_PARTIDO_DOADOR, VR_RECEITA) %>% 
    mutate(VR_RECEITA = as.numeric(gsub(",", ".", VR_RECEITA)))
  
  receitas_filtradas <- receitas %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador"),
           SG_PARTIDO == SG_PARTIDO_DOADOR) %>% 
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


#' @title Importa dados de receitas dos candidatos em eleições anteriores a 2018 (usa o formato antigo dos dados do TSE)
#' @description Importa usando o formato antigo dos dados do TSE os dados de receitas dos candidatos
#' @param datapath Caminho para os dados de receita (.txt)
#' @return Dataframe contendo receitas dos candidatos com colunas específicas
#' @examples
#' receitas <- import_receita_tse_modelo_antigo()
import_receita_tse_modelo_antigo <- function(datapath = here::here("crawler/parlamentares/receitas/receitas_candidatos_2014_brasil.txt")) {
  library(tidyverse)
  library(here)
  
  receita_tse <- read_delim(datapath, delim = ";", 
                            col_types = cols(`Sequencial Candidato` = "c", `Valor receita` = "c"), 
                            locale = locale(encoding = 'latin1')) %>% 
    select(SQ_CANDIDATO = `Sequencial Candidato`, NR_CPF_CNPJ_DOADOR = `CPF/CNPJ do doador`,
           NM_DOADOR = `Nome do doador`, NM_DOADOR_RFB = `Nome do doador (Receita Federal)`,
           DS_ORIGEM_RECEITA = `Tipo receita`, VR_RECEITA = `Valor receita`)
  
  return(receita_tse)
}

#' @title Processa dados de receitas dos candidatos em 2018 para Deputado e Senador
#' @description Sumariza dados de receitas e apresenta os doadores para a campanha do candidato. 
#' Esse tratamento é realizado tendo como entrada os dados do TSE de declaração dos bens do candidato.
#' @param receitas_datapath Caminho para os dados de receitas
#' @param candidatos_datapath Caminho para os dados de candidatos nas eleições de 2018
#' @param ano Ano da eleição
#' @return Dataframe contendo doações feitas por partidos, candidatos e pessoas físicas para os candidatos em 2018
#' @examples
#' doacoes <- processa_doacoes_tse()
#' Foram filtrados os candidatos apenas dos cargos de Senador e Deputado Federal.
#' Obs: Assume que os dados de receitas e  candidatos estão disponíveis. Esses dados pode ser baixados 
#' através do script ./fetcher_receitas_tse.sh
processa_doacoes_tse <- function(
  receitas_datapath = here::here("crawler/parlamentares/receitas/receitas_candidatos_2018_BRASIL.csv"),
  candidatos_datapath = here::here("crawler/parlamentares/receitas/consulta_cand_2018_BRASIL.csv"),
  ano = 2018) {
  
  library(tidyverse)
  library(here)
  
  candidatos <- read_delim(candidatos_datapath, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                           locale = locale(encoding = 'latin1')) %>% 
    filter(DS_SITUACAO_CANDIDATURA == "APTO") %>% 
    filter(DS_DETALHE_SITUACAO_CAND %in% c("DEFERIDO", "DEFERIDO COM RECURSO")) %>% 
    select(DS_CARGO, SG_UE, SQ_CANDIDATO, NM_CANDIDATO, NR_CPF_CANDIDATO, SG_PARTIDO) %>% 
    mutate(DS_CARGO = str_to_title(DS_CARGO)) %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador"))
  
  if (ano == 2018) {
    receitas <- read_delim(receitas_datapath, delim = ";", col_types = cols(SQ_CANDIDATO = "c", VR_RECEITA = "c"),
                           locale = locale(encoding = 'latin1')) %>% 
      select(SQ_CANDIDATO, NR_CPF_CNPJ_DOADOR, NM_DOADOR, NM_DOADOR_RFB, DS_ORIGEM_RECEITA, VR_RECEITA)  
  } else {
    receitas <- import_receita_tse_modelo_antigo(receitas_datapath)
  }
  
  receitas <- receitas %>% 
    mutate(VR_RECEITA = as.numeric(gsub(",", ".", VR_RECEITA))) %>% 
    
    group_by(SQ_CANDIDATO, NR_CPF_CNPJ_DOADOR) %>% 
    summarise(NM_DOADOR = first(NM_DOADOR),
              NM_DOADOR_RFB = first(NM_DOADOR_RFB),
              DS_ORIGEM_RECEITA = first(DS_ORIGEM_RECEITA),
              VR_RECEITA = sum(VR_RECEITA))
  
  candidatos_doacoes <- candidatos %>% 
    left_join(receitas, by = c("SQ_CANDIDATO")) %>% 
    mutate(total_receita = if_else(is.na(VR_RECEITA), 0, VR_RECEITA))
  
  return(candidatos_doacoes)
}

#' @title Processa dados de receitas dos deputados em exercício
#' @description Recupera informações dos doadores para a campanha dos deputados nas eleições de 2018
#' @param ano Ano da eleição
#' @return Dataframe contendo doações feitas por partidos, candidatos e pessoas físicas para os deputados
#' @examples
#' deputados_doadores <- processa_doacoes_deputados_tse()
processa_doacoes_deputados_tse <- function(ano = 2018) {
  library(tidyverse)
  library(here)
  source(here("crawler/parlamentares/receitas/utils_receitas.R"))
  
  if(ano == 2018) {
    receitas_datapath <- .DATAPATH_RECEITA_TSE_2018
    candidatos_datapath <- .DATAPATH_CANDIDATOS_TSE_2018
  } else if (ano == 2014) {
    receitas_datapath <- .DATAPATH_RECEITA_TSE_2014
    candidatos_datapath <- .DATAPATH_CANDIDATOS_TSE_2014
  } else {
    stop("Ano não disponível para captura dos dados de receita")
  }
  
  receitas_datapath <- here(receitas_datapath)
  candidatos_datapath <- here(candidatos_datapath)
  
  doacoes <- processa_doacoes_tse(receitas_datapath, candidatos_datapath, ano = ano) %>% 
    select(cpf = NR_CPF_CANDIDATO, cpf_cnpj_doador = NR_CPF_CNPJ_DOADOR, nome_doador = NM_DOADOR_RFB, 
           origem_receita = DS_ORIGEM_RECEITA, valor_receita = VR_RECEITA)
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == "camara", em_exercicio == 1)
  
  deputados_doacoes <- deputados %>% 
    left_join(doacoes, by = "cpf")

  return(deputados_doacoes)  
}

#' @title Importa dados de candidatos disponibilizados pelo TSE
#' @description Importa os dados (csv ou txt) dos candidatos. A base é disponibilizada pelo TSE.
#' @param datapath Caminho para o arquivo com os dados dos candidatos
#' @param complete Se TRUE retorna informações mais completas sobre os candidatos (mais colunas). FALSE por default.
#' @return Dataframe
#' contendo, se complete = FALSE ano da eleição, cpf do candidato, cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- import_candidatos("./candidatos.csv", 2018)
#' candidatos <- import_candidatos("./candidatos.csv", 2018, complete = TRUE)
import_candidatos <- function(data_path, year, complete = FALSE) {
  if (year == 2018) {
    return(import_candidatos_modelo2018(data_path, complete))
  } else if (year == 2014) {
    return(import_candidatos_modelo2018(data_path))
  } else if (year == 2010) {
    return(import_candidatos_modelo2010(data_path))
  }
}

#' @title Importa dados de candidatos disponibilizados pelo TSE
#' @description Importa os dados dos candidatos considerando o ano de 2010. A base é disponibilizada pelo TSE e o modelo com as colunas também.
#' @param datapath Caminho para o arquivo com os dados dos candidatos
#' @return Dataframe
#' contendo ano da eleição, cpf do candidato, cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- import_candidatos_modelo2010("./candidatos.csv")
import_candidatos_modelo2010 <- function(data_path){
  library(tidyverse)
  
  candidatos_2010 <- read_delim(data_path, delim = ";", col_names = FALSE, 
                                col_types = "cciicccciccciccicicccccciccciicicicicccciic",
                                locale = locale(encoding = "latin1"))
  
  colunas_candidatos <- c("data_geracao", "hora_geracao", "ano_eleicao", "num_turno", "desc_eleicao",  "sigla_UF", 
                          "sigla_unid_eleitoral", "desc_unid_eleitoral", "cod_cargo", "desc_cargo", "nome_candidato", 
                          "sequencial_candidato", "numero_candidato", "cpf_candidato","nome_urna_candidato", 
                          "cod_situacao_candidatura", "desc_situacao_candidatura", "numero_partido", "sigla_partido", 
                          "nome_partido", "cod_legenda", "sigla_legenda", "composicao_legenda", "nome_legenda", 
                          "cod_ocupacao", "desc_ocupacao", "data_nascimento", "num_titulo_eleitoral_cand", "idade_cand_data_eleicao",
                          "cod_genero", "desc_genero", "cod_grau_instrucao", "desc_grau_instrucao", "cod_estado_civil", "desc_estado_civil", 
                          "cod_nacionalidade", "desc_nacionalidade", "sigla_UF_nasc", "cod_municipio_nasc", 
                          "nome_municipioNasc", "despesa_max_campanha", "cod_situacao_eleito", "desc_situacao_eleito")
  
  
  colnames(candidatos_2010) <- colunas_candidatos
  
  candidatos_2010 <- candidatos_2010 %>%
    mutate(email = "#NE") %>%
    mutate(codCorRaca = -3) %>%
    mutate(descCorRaca = "#NE") %>%
    select("ano_eleicao", "cpf_candidato", "cod_cargo", "desc_cargo", "sequencial_candidato", "nome_urna_candidato", "nome_candidato")
  
  return(candidatos_2010)
}

#' @title Importa dados de candidatos disponibilizados pelo TSE
#' @description Importa os dados dos candidatos considerando o ano de 2018. A base é disponibilizada pelo TSE e o modelo com as colunas também.
#' @param datapath Caminho para o arquivo com os dados dos candidatos
#' @param complete Se TRUE retorna informações mais completas sobre os candidatos (mais colunas). FALSE por default.
#' @return Dataframe
#' contendo, se complete = FALSE, ano da eleição, cpf do candidato, cargo, sequencial do candidato na eleição, nome de urna do candidato e o nome completo.
#' @examples
#' candidatos <- import_Candidatos_modelo2010("./candidatos.csv")
#' candidatos <- import_Candidatos_modelo2010("./candidatos.csv", complete = TRUE)
import_candidatos_modelo2018 <- function(data_path, complete = FALSE) {
  library(tidyverse)
  
  candidatos_2018 <- read_delim(data_path, delim = ";", col_names = TRUE,
                                locale = locale(encoding = "latin1"),
                                col_types = "cciicciccccccicccccccciciccicccccicccccicicicicicicniccccc")

  colunas_candidatos <- c("data_geracao", "hora_geracao", "ano_eleicao", "cod_tipo_eleicao", "desc_tipo_eleicao", "num_turno", 
                          "cod_eleicao", "desc_eleicao", "data_eleicao", "tipo_abrangencia", "sigla_UF", "sigla_unid_eleitoral",
                          "desc_unid_eleitoral", "cod_cargo", "desc_cargo", "sequencial_candidato", "numero_candidato", "nome_candidato",
                          "nome_urna_candidato", "nome_social_candidato", "cpf_candidato", "email", "cod_situacao_candidatura", 
                          "desc_situacao_candidatura", "cod_detalhe_situacao_cand", "desc_detalhe_situacao_cand", "tipo_agremiacao", 
                          "numero_partido", "sigla_partido", "nome_partido", "cod_legenda", "nome_legenda", "composicao_legenda", 
                          "cod_nacionalidade", "desc_nacionalidade", "sigla_UF_nasc", "cod_municipio_nasc", "nome_municipio_nasc", 
                          "data_nascimento", "idade_cand_data_eleicao", "num_titulo_eleitoral_cand", "cod_genero", "desc_genero", 
                          "cod_grau_instrucao", "desc_grau_instrucao","cod_estado_civil", "desc_estado_civil", "cod_cor_raca", 
                          "desc_cor_raca", "cod_ocupacao", "desc_ocupacao", "despesa_max_campanha", "cod_situacao_eleito", 
                          "desc_situacao_eleito", "situacao_reeleicao", "situacao_declarar_bens", "num_protocolo_candidatura", "num_processo")
  
  colnames(candidatos_2018) <- colunas_candidatos
  
  if (complete) {
    col_select <- c("cod_cargo", "sigla_UF", "desc_unid_eleitoral", "nome_candidato", "nome_urna_candidato", 
                    "nome_social_candidato", "email", "tipo_agremiacao", "numero_partido", "sigla_partido", 
                    "nome_partido", "nome_legenda", "composicao_legenda", "idade_cand_data_eleicao", 
                    "desc_genero", "desc_grau_instrucao", "desc_cor_raca", "desc_ocupacao", "cpf_candidato", 
                    "situacao_reeleicao")
  } else {
    col_select <- c("ano_eleicao", "cpf_candidato", "cod_cargo", "desc_cargo", "sequencial_candidato", "situacao_reeleicao", 
                    "nome_urna_candidato", "nome_candidato")
  }
  
  candidatos_2018 <- candidatos_2018 %>% 
    mutate(siglaLegenda = "#NE#") %>%
    select(col_select)
  
  return(candidatos_2018)
}

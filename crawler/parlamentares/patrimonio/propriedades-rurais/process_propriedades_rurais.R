#' @title Processa dados de propriedades rurais de candidatos a Deputado Federal e Senador nas eleições de 2018
#' @description A partir de um csv da declaração de bens dos candidatos ao TSE filtra os bens considerados como 
#' propriedades rurais.
#' @param bens_data_path Caminho para os dados de bens declarados ao TSE
#' @param candidatos_data_path Caminho para os dados de candidatos nas eleições de 2018
#' @return Dataframe contendo bens de propriedades rurais.
#' @examples
#' propriedades_rurais <- process_propriedades_rurais()
#' 
#' Observações 
#' 1. Obtenha os dados usados como entrada dessa função executando o arquivo fetcher_patrimonio_tse.sh presente
#' no mesmo diretório deste arquivo
#' 2. A classificação de um bem como sendo propriedade rural é feita utilizando um conjunto de exemplos que 
#' pode ser observado na variavel classificacao_rural do código abaixo.
process_propriedades_rurais <- function(
  bens_data_path = here::here("crawler/parlamentares/patrimonio/propriedades-rurais/bem_candidato_2018_BRASIL.csv"),
  candidatos_data_path = here::here("crawler/parlamentares/patrimonio/propriedades-rurais/consulta_cand_2018_BRASIL.csv")
  ) {
  
  library(tidyverse)
  library(here)
  
  classificacao_rural <- c("lote rural", "lotes rurais", "imovel rural", "imoveis rurais",
                           "gleba de terra", "fazenda", "agricola", "sitio", "rurais", "chacara", 
                           "area rural", "areas rurais", "area no loteamento", "terreno agricola", 
                           "terrenos agricolas", "estabelecimento rural", "estabelecimentos rurais",
                           "atividade agricola", "atividade agricolas", "terra rural", "terras rurais",
                           "lt rural", "propriedade rural", "propriedades rurais", "zona rural", 
                           "zonas rurais", "Lote Colonial Rural", "terreno rural")
  
  bens <- read_delim(bens_data_path, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                           locale = locale(encoding = 'latin1'))
    
  bens_rurais <- bens %>% 
    filter(str_detect(tolower(iconv(DS_BEM_CANDIDATO, 
                 from = "UTF-8", 
                 to = "ASCII//TRANSLIT")), paste(classificacao_rural, collapse = "|"))) %>% 
    mutate(VR_BEM_CANDIDATO = as.numeric(gsub(",", ".", VR_BEM_CANDIDATO))) %>% 
    select(SQ_CANDIDATO, DS_BEM_CANDIDATO, VR_BEM_CANDIDATO)
  
  candidatos <- read_delim(candidatos_data_path, delim = ";", col_types = cols(SQ_CANDIDATO = "c"),
                           locale = locale(encoding = 'latin1')) %>% 
    mutate(DS_CARGO = str_to_title(DS_CARGO)) %>% 
    filter(DS_CARGO %in% c("Deputado Federal", "Senador")) %>% 
    select(SQ_CANDIDATO, NR_CPF_CANDIDATO, DS_CARGO, SG_UE, SG_PARTIDO)
  
  candidatos_bens_rurais <- candidatos %>% 
    inner_join(bens_rurais, by = "SQ_CANDIDATO")
  
  return(candidatos_bens_rurais)
}

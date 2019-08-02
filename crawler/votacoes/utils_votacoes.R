#' @title Enumera votações
#' @description Recebe um dataframe com coluna voto e enumera o valor para um número
#' @param df Dataframe com a coluna voto
#' @return Dataframe com coluna voto enumerada
#' @examples
#' enumera_votacoes(df)
enumera_voto <- function(df) {
  df %>%
    mutate(
      voto = case_when(
        str_detect(voto, "Não") ~ -1,
        str_detect(voto, "Sim") ~ 1,
        str_detect(voto, "Obstrução|P-OD") ~ 2,
        str_detect(voto, "Abstenção") ~ 3,
        str_detect(voto, "Art. 17|art. 51 RISF") ~ 4,
        str_detect(voto, "Liberado") ~ 5,
        #TODO: Tratar caso P-NRV: Presente mas não registrou foto
        TRUE ~ 0
      )
    )
}

#' @title Padroniza siglas de partidos
#' @description Recebe uma sigla de partido como input e retorna seu valor padronizado
#' @param sigla Sigla do partido
#' @return Dataframe com sigla do partido padronizada
padroniza_sigla <- function(sigla) {
  sigla = toupper(sigla)
  
  sigla_padronizada <- case_when(
    str_detect(tolower(sigla), "ptdob") ~ "AVANTE",
    str_detect(tolower(sigla), "pcdob") ~ "PCdoB",
    str_detect(tolower(sigla), "ptn") ~ "PODEMOS",
    str_detect(tolower(sigla), "pps") ~ "CIDADANIA",
    str_detect(tolower(sigla), "pmdb") ~ "MDB",
    tolower(sigla) == "pr" ~ "PL",
    str_detect(sigla, "SOLID.*") ~ "SOLIDARIEDADE",
    str_detect(sigla, "PODE.*") ~ "PODEMOS",
    str_detect(sigla, "GOV.") ~ "GOVERNO",
    str_detect(sigla, "PHS.*") ~ "PHS",
    TRUE ~ sigla
  ) %>%
    stringr::str_replace("REPR.", "") %>% 
    stringr::str_replace_all("[[:punct:]]", "") %>% 
    trimws(which = c("both"))
  
  return(sigla_padronizada)
}

#' @title Recupera descrição do voto a partir do código enumerado do voto
#' @description Recebe um integer que representa o código do voto e retorna a descrição do mesmo
#' @param voto Voto para descrição
#' @return Descrição do voto apssado como parâmetro
#' @examples
#' get_descricao_voto(2)
get_descricao_voto <- function(voto) {
  voto_descricao <- case_when(
    voto == -1 ~ "Não",
    voto == 1 ~ "Sim",
    voto == 2 ~ "Obstrução",
    voto == 3 ~ "Abstenção",
    voto == 4 ~ "Art. 17",
    voto == 5 ~ "Liberado",
    TRUE ~ "Não votou")
  
  return(voto_descricao)
}

#' @title Recupera o título de uma proposição a partir de seu id
#' @description Recebe o id de uma proposição na câmara e retorna seu título
#' @param id_proposicao Id da proposição
#' @return Título da proposicao (ex: MPV 867/2018)
#' @examples
#' get_sigla_by_id_camara(2190237) // "MPV 867/2018"
get_sigla_by_id_camara <- function(id_proposicao) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  
  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterProposicaoPorID?IdProp=", id_proposicao)
  
  xml <- getURL(url) %>%
    read_xml()
  
  atributos <- xml_attrs(xml, "id") %>% 
    as.list() %>% 
    data.frame(stringsAsFactors = F) %>% 
    mutate(tipo = trimws(tipo, which = c("both"))) %>% 
    select(siglaTipo = tipo, numero, ano)
    
  return(atributos)
}

#' @title Mapeia um nome eleitoral para id correspondente
#' @description Recebe dois dataframes contendo nome eleitoral e um deles com informação de id
#' @param target_df Dataframe a receber o id do parlamentar
#' @return Dataframe target_df contendo coluna id
mapeia_nome_eleitoral_to_id_senado <- function(target_df) {
  library(tidyverse)
  
  senadores_df <- read_csv(here::here("crawler/raw_data/senadores.csv"))
  
  result <- 
    target_df %>% 
    left_join(
      senadores_df %>%
        select(nome_eleitoral, id), 
         by=c("nome_eleitoral"))
  
  return(result)
}

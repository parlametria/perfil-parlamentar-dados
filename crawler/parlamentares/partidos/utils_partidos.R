#' @title Padroniza palavra para comparação
#' @description Recebe uma palavra, retira acentos e deixa em uppercase.
#' @param string Palavra a ser padronizada
#' @return Palavra padronizada
padroniza_string <- function(string) {
  string = iconv(toupper(string), to = "ASCII//TRANSLIT")
  return(string)
}

#' @title Mapeia sigla de partido para id
#' @description Recebe um dataframe contendo uma coluna 'partido' com a sigla de um partido e retorna o id correspondente
#' @param df Dataframe com uma coluna 'partido'
#' @param parlamentares_path Caminho para o arquivo de dados dos parlamentares
#' @param partidos_path Caminho para o arquivo dos dados do partidos
#' @return Dataframe com nova coluna id_partido
map_sigla_to_id <- function(df, 
                            parlamentares_path = here::here("crawler/raw_data/parlamentares.csv"),
                            partidos_path = here::here("crawler/raw_data/partidos.csv")) {
  
  deputados <- read_csv(parlamentares_path, col_types = cols(id = "c")) %>% 
    filter(casa == "camara") %>% 
    select(id_partido = num_partido, sg_partido) %>% 
    mutate(sg_partido = padroniza_string(sg_partido))
  
  partidos <- 
    read_csv(partidos_path, col_types = cols(.default = "c", id = "i")) %>% 
    select(-c(situacao, tipo)) %>% 
    mutate(sigla = padroniza_string(sigla))
  
  partidos <- partidos %>% 
    rbind(
      anti_join(deputados, 
                partidos, 
                by = c("sg_partido" = "sigla")) %>% 
        unique() %>% 
        rename(id = id_partido, sigla = sg_partido))
  
  df <- df %>% 
    mutate(partido = padroniza_string(partido)) %>% 
    left_join(partidos, by = c("partido" = "sigla")) %>% 
    unique() %>% 
    rename(id_partido = id)
  
  return(df)
  
}


#' @title Mapeia sigla padronizada para sigla usada na tabela de partidos (crawler/raw_data/partidos.csv)
#' @description Recebe uma string com a sigla padronizada do partido e retorna a sigla correspondente na
#' tabela de partidos
#' @param sigla Sigla padronizada do partido (string)
#' @return Sigla correspondente em crawler/raw_data/partidos.csv
map_sigla_padronizada_para_sigla <- function(sigla) {
  library(tidyverse)
  
  sigla_clean <- padroniza_string(sigla)
  
  sigla_alt <- case_when(
    str_detect(sigla_clean, "PODEMOS") ~ "PODE",
    str_detect(sigla_clean, "BLOCO PP MDB PTB") ~ "BLOCO PP, MDB, PTB",
    str_detect(sigla_clean, "BLOCO PARLAMENTAR PSDBPSL") ~ "BLOCO PARLAMENTAR PSDB/PSL",
    TRUE ~ sigla_clean
  )
  
  return(sigla_alt)
}

#' @title Mapeia sigla de partido para id
#' @description Recebe uma string com a sigla do partido e retorna qual o ID deste partido
#' @param sigla Sigla do partido (string)
#' @return Id do partido
map_sigla_id <- function(sigla_partido) {
  library(tidyverse)
  library(here)
  source(here("crawler/votacoes/utils_votacoes.R"))
  
  partidos <- suppressWarnings(suppressMessages(read_csv(here("crawler/raw_data/partidos.csv"))))
  
  sigla_padronizada <- padroniza_sigla(sigla_partido) %>% 
    padroniza_string()
  
  id_partido <- partidos %>% 
    filter(padroniza_string(sigla) == map_sigla_padronizada_para_sigla(sigla_padronizada)) %>%
    pull(id)
  
  if (length(id_partido) == 0) {
    return(partidos %>% filter(sigla == "SPART") %>% pull(id))
  } else {
    return(id_partido)
  }
}

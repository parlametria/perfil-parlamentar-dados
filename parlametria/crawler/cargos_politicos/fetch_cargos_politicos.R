#' @title Baixa os dados de um conjunto de anos e para um conjunto de cargos
#' @description A partir de um conjunto de anos e um conjunto de cargos, acessa a biblioteca feita pela CEPESP
#' e retorna os dados dos candidatos eleitos em cada cargo e ano selecionado.
#' @param anos Conjunto de anos de eleições
#' @param cargos Conjunto de cargos de eleições
#' @param nivel_detalhamento Nível de detalhamento dos resultados. Pode ser:
#' Brasil, Macro, Estado, Meso, Micro, Municipio, Municipio-Zona, Zona, Votação e Seção.
#' @param elected TRUE para filtrar apenas candidatos eleitos, FALSE caso contrário.
#' @return Dataframe com informações sobre candidatos eleitos em cargos e anos específicos.
#' @example fetch_eleicoes()
fetch_eleicoes <- function(
  anos = c(2018), 
  cargos = c("Presidente", "Governador", "Senador", "Deputado Federal", "Deputado Estadual"),
  nivel_detalhamento = "Brasil",
  elected = TRUE
  ) {
  
  library(tidyverse)
  library(cepespR)
  library(purrr)
  
  eleicoes <- map_df(anos, function(x) {
    data <- 
      map_df(
        cargos,
        function(y) {
          print(paste0("Baixando resultado das eleições de ", x, " para o cargo ", y, "..."))
          
          eleicao <- get_elections(x, 
                                   only_elected = elected,
                                   position = y,
                                   regional_aggregation = nivel_detalhamento) %>% 
            mutate(CPF_CANDIDATO = as.character(CPF_CANDIDATO))
          
          if (nivel_detalhamento == "Municipio") {
            eleicao <- eleicao %>% 
              mutate(SIGLA_UE = NOME_MUNICIPIO) %>% 
              mutate(SIGLA_UF = UF)
          }
          
          if (nivel_detalhamento == "Brasil") {
            eleicao <- eleicao %>% 
              mutate(SIGLA_UF = SIGLA_UE)
          }
          
          return(eleicao %>%
                   select(CPF_CANDIDATO,
                          ANO_ELEICAO,
                          NUM_TURNO,
                          DESCRICAO_CARGO,
                          SIGLA_UE,
                          SIGLA_UF,
                          DES_SITUACAO_CANDIDATURA,
                          DESC_SIT_TOT_TURNO,
                          SIGLA_PARTIDO,
                          QTDE_VOTOS)
                 )
        }
      )
  })
  
  return(eleicoes)
} 

#' @title Baixa todos os cargos de eleição desde 1998
#' @description Baixa e processa os cargos políticos e seus ocupantes desde 1998.
#' @param parlamentares_datapath Caminho para o arquivo csv dos parlamentares que se deseja extrair 
#' cargos políticos.
#' @return Dataframe contendo os cargos políticos de 1998 a 2018.
#' @example fetch_all_cargos_politicos()
fetch_all_cargos_politicos <- function(parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(purrr)
  library(here)
  source(here("crawler/parlamentares/process_cpf_parlamentares.R"))
  
  cargos_nacionais <- list(cargos = c("Presidente", "Governador", "Senador", "Deputado Federal", "Deputado Estadual"),
                           elected = c(TRUE, TRUE, FALSE, FALSE, TRUE))
  anos_eleicoes_nacionais <- seq(1998, 2018, 4)
  cargos_eleicoes_nacionais <- purrr::map2_df(cargos_nacionais$cargos,
                                              cargos_nacionais$elected,
                                              ~ fetch_eleicoes(anos_eleicoes_nacionais,
                                              .x, 
                                              elected = FALSE))
  
  cargos_municipais <- c("Vereador", "Prefeito")
  anos_eleicoes_municipais <- seq(2000, 2016, 4)
  cargos_eleicoes_municipais <- fetch_eleicoes(anos_eleicoes_municipais,
                                               cargos_municipais,
                                               "Municipio")
  
  todos_cargos <- rbind(cargos_eleicoes_nacionais, 
                        cargos_eleicoes_municipais)
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(cpf = "c", id = "c")) %>% 
    filter(ultima_legislatura == 56)
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador) %>% 
    distinct()

  cargos_parlamentares <- parlamentares %>% 
    left_join(todos_cargos, by = c("cpf" =  "CPF_CANDIDATO"))
  
  return(cargos_parlamentares)
}

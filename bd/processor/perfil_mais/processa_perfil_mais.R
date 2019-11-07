#' @title Cria tabela com dados do perfil mais
#' @description Cria tabela com índices gerados para o perfil mais
#' @param perfilmais_data_path Caminho para o arquivo de dados gerados para o perfil mais
#' @return Dataframe com informações do perfil mais
processa_perfil_mais <- 
  function(perfil_mais_data_path = here::here("parlametria/raw_data/dados_perfil_mais.csv")) {
  
  library(tidyverse)
  library(here)
  
  perfil_mais <- read_csv(perfil_mais_data_path, col_types = cols(id = "c"))
    
  perfil_mais_alt <- perfil_mais %>% 
    mutate(
      casa_enum = dplyr::if_else(casa == "camara", 1, 2),
      id_parlamentar_voz = paste0(casa_enum, as.character(id))
    ) %>% 
    select(id_parlamentar_voz, indice_vinculo_economico_agro,
           indice_ativismo_ambiental, peso_politico = indice_influencia_parlamentar)

  return(perfil_mais_alt)
}

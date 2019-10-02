#' @title Cruza todos os dados usados para construção dos índices relacionados a parlamentares
#' @description Monta um dataframe com base nos indíces de vínculo com o agro, ativismo ambiental e vínculo com agro
#' @return Dataframe com cruzamos dos dados relacionados a parlamentares e seus índices de relação com o Meio Ambiente e o Agronegócio.
#' @examples
#' planilha <- process_indices_parlametria()
process_indices_parlametria <- function() {
  library(tidyverse)
  library(here)
  here <- here::here
  
  source(here("parlametria/processor/processor_indice_vinculo_agro.R"))
  source(here("parlametria/processor/processor_indice_ativismo_ambiental.R"))
  source(here("parlametria/processor/processor_influencia_parlamentar.R"))
  source(here("parlametria/processor/get_info_parlamentares.R"))
  
  indice_vinculo_economico <- process_indice_vinculo_agro()
  
  indice_ativismo_ambiental <- process_indice_ativismo_ambiental() %>% 
    mutate(id = as.character(id))
  
  indice_influencia_parlamentar <- process_indice_influencia_parlamentar()
  
  info_basicas_parlamentares <- get_info_parlamentares_em_exercicio() %>% 
    filter(casa == "camara")

  parlamentares <- info_basicas_parlamentares %>% 
    left_join(indice_vinculo_economico, by = "id") %>% 
    left_join(indice_ativismo_ambiental, by = "id") %>% 
    left_join(indice_influencia_parlamentar, by = "id")
  
  return(parlamentares)
}

#' @title Classifica deputados em grupos ("Oposição", "Vínculo com o Agro", "Zona Cinza")
#' @description A partir da lista de parlamentares classifica-os de acordo com o 
#' grupo correspondente ("Oposição", Vínculo com o Agro", "Zona Cinza")
#' @return Dataframe com informações dos parlamentares e seus grupos
#' @examples
#' parlamentares <- agrupa_parlamentares_parlametria()
agrupa_parlamentares_parlametria <- function() {
  library(tidyverse)
  library(here)
  
  parlamentares <- process_indices_parlametria()
  
  partidos_oposicao <- c("PT", "PSOL", "PCdoB", "PDT", "PSB", "PV", "REDE")
  
  grupo_agro <- "Vínculo com o Agro"
  grupo_zona_cinza <- "Zona cinza"
  grupo_oposicao <- "Oposição"
  
  parlamentares_classificados <- parlamentares %>% 
    mutate(grupo = case_when(
      sg_partido %in% partidos_oposicao ~ grupo_oposicao,
      indice_vinculo_economico_agro > 0 ~ grupo_agro,
      indice_vinculo_economico_agro <= 0 ~ grupo_zona_cinza
    )) %>% 
    mutate(subgrupo = case_when(
      grupo == grupo_agro &
        indice_vinculo_economico_agro > 0 &
        indice_ativismo_ambiental >= 0.05 ~ "Financiados pelo Agro e simpáticos ao Meio Ambiente",
      
      # grupo == grupo_agro & ## TODO colunas porcentagem_doacoes_empresas_agro_exportadoras e tem_empresa_exportadora
      #   ( porcentagem_doacoes_empresas_agro_exportadoras > 0.1 | 
      #     tem_empresa_exportadora == 1
      #   ) &
      #   indice_ativismo_ambiental < 0.05 ~ "Financiado pelo agro e ligado a exportação",
      
      grupo == grupo_zona_cinza &
        indice_ativismo_ambiental > 0.01 ~ "Sem vínculo econômico, mas ativistas ambientais",
      
      grupo == grupo_oposicao &
        indice_ativismo_ambiental >= 0.2 ~ "Oposição e alto ativismo ambiental",
    ))
  
  return(parlamentares_classificados)
}


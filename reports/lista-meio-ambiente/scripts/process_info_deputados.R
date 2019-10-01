#' @title Agrega e retorna informações de deputados coletadas de diversas fontes
#' @description Agrega e cruza dados de diversas fontes de dados com o objetivo de montar dataframe 
#' com variáveis prontas para serem usadas como entrada para aplicação de Redução de dimensionalidade (PCA)
#' @return Dataframe contendo informações sobre os deputados
#' @examples
#' info_deputadsos <- process_info_deputados()
process_info_deputados <- function() {
  library(tidyverse)
  library(here)
  
  deputados <- read_csv(here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c")) %>% 
    filter(casa == "camara", em_exercicio == 1) %>% 
    select(id, nome_eleitoral, sg_partido, uf)
  
  ## Vínculo com o Agro
  vinculo_agro <- read_csv(here("parlametria/raw_data/score_ruralistas/indice_vinculo_economico_agro.csv"), col_types = cols(id = "c")) %>% 
    mutate(proporcao_doacoes_agro = if_else(is.na(proporcao_doacoes_agro), 0, proporcao_doacoes_agro)) %>% 
    select(id, total_declarado, numero_empresas_associadas, proporcao_doacoes_agro)

  ## Aderência ao Governo em votações de Meio Ambiente em 2019
  aderencia <- read_csv(here("crawler/raw_data/parlamentares_aderencia.csv"), col_types = cols(id = "c")) %>% 
    select(id, aderencia)
  
  ## Investimento recebido pelo partido nas eleições de 2018
  investimento_partido <- read_csv(here("crawler/raw_data/parlamentares_investimento.csv"), col_types = cols(id = "c")) %>% 
    select(id, proporcao_campanhas_medias_receita)
  
  ## Número de frentes associadas ao Meio Ambiente
  
  # frente, id
  # Frente Parlamentar da Agropecuária - FPA, 53910
  # Frente Parlamentar Ambientalista, 54012
  # Frente Parlamentar Mista em Defesa dos Direitos dos Povos Indígenas, 53999
  # Frente Parlamentar Mista da Mineração, 54080
  # Frente Parlamentar pelo Livre Mercado, 54016
  frentes_meio_ambiente <- read_csv(here("crawler/raw_data/frentes/frentes.csv")) %>% 
    select(id_frente, titulo_frente) %>% 
    filter(id_frente %in% c(53910, 54012, 53999, 54080, 54016))
  
  membros_frentes_meio_ambiente <- read_csv(here("crawler/raw_data/frentes/membros_frentes.csv"), col_types = cols(id = "c")) %>% 
    distinct(id, id_frente) %>% 
    filter(id_frente %in% (frentes_meio_ambiente %>% pull(id_frente))) %>% 
    
    group_by(id) %>% 
    summarise(n_frentes = n())
  
  ## Atuação em proposições de Meio Ambiente
  autores_meio_ambiente <- read_csv(here("crawler/raw_data/atores_meio_ambiente.csv"), col_types = cols(id_autor = "c")) %>% 
    group_by(id_autor) %>% 
    summarise(total_documentos = sum(qtd_de_documentos)) %>% 
    rename(id = id_autor)
  
  deputados_merge <- deputados %>% 
    left_join(vinculo_agro, by = "id") %>% 
    left_join(aderencia, by = "id") %>% 
    left_join(investimento_partido, by = "id") %>% 
    left_join(membros_frentes_meio_ambiente, by = "id") %>% 
    left_join(autores_meio_ambiente, by = "id")
      
  return(deputados_merge)
}

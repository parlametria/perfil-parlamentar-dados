#' @title Retorna o id de um tema dado sem nome
#' @description A partir do nome do tema retorna seu id
#' @param tema_nome Nome do tema
#' @return Inteiro com o id do tema
#' @examples
#' tema_id <- getIdfromTema("Meio Ambiente")
getIdfromTema <- function(tema_nome) {
  library(tidyverse)
  
  tema_id <- case_when(
    tolower(tema_nome) == tolower("Meio Ambiente") ~ 0,
    tolower(tema_nome) == tolower("Direitos Humanos") ~ 1,
    tolower(tema_nome) == tolower("Integridade e Transparência") ~ 2,
    tolower(tema_nome) == tolower("Agenda Nacional") ~ 3,
    tolower(tema_nome) == tolower("Educação") ~ 5,
    TRUE ~ 99
  )
  
  return(tema_id)
}

#TODO
getIdfromListaTema <- function(tema_nome, temas) {
  library(tidyverse)
  
  tema_nome <- tolower(tema_nome)
  
  tema_id <- 
  if(tema_nome %in% sapply(temas$tema, tolower)) {
    as.numeric(temas %>% filter(tolower(tema) == tema_nome) %>% pull(id_tema))
  } else {
    99
  }
  
  return(tema_id)
}

#' @title Retorna as proposições selecionadas votadas em plenários e seus temas 
#' (mais de uma observação por proposição se houver mais de uma tema para a proposição)
#' @description IDs dos temas das proposições selecionadas
#' @param url URL para os dados de proposições votadas na legislatura atual
#' @return Dataframe com proposições e os temas (ids)
#' @examples
#' proposicoes_temas <- process_proposicoes_plenario_selecionadas_temas(url)
process_proposicoes_plenario_selecionadas_temas <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_PLENARIO_CAMARA
  }
  
  proposicoes <- read_csv(url, col_types = cols(id = "c"))
  
  proposicoes_va <- proposicoes %>% 
    filter(tolower(tema_va) != "não entra") %>% 
    mutate(tema = strsplit(as.character(tema_va), ";")) %>% 
    unnest(tema) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(id_tema = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    mutate(id_proposicao = id) %>% 
    distinct(id_proposicao, id_tema)
  
  return(proposicoes_va)
}

#' @title Retorna as todas as proposições votadas em plenários e seus temas 
#' (mais de uma observação por proposição se houver mais de uma tema para a proposição)
#' @description IDs dos temas das proposições
#' @param proposicoes dataframe contendo todas proposicoes de interesse
#' @param casa_aderencia determina qual casa deseja adquirir os temas
#' @return Dataframe com proposições e os temas (ids)
process_proposicoes_plenario_temas <- function(proposicoes, casa_aderencia = "camara", temas) {
    if(casa_aderencia == "camara") {
      proposicoes_va <- proposicoes %>% 
      mutate(tema = map_chr(id_proposicao, fetch_apenas_tema_proposicao)) %>%
      mutate(tema = strsplit(as.character(tema), ";")) %>%
      unnest(tema) %>%
      ungroup() %>%
      rowwise() %>% 
      mutate(id_tema = getIdfromListaTema(tema, temas)) %>%
      ungroup() %>%
      mutate(id_proposicao = id_proposicao) %>%
      distinct(id_proposicao, id_tema)
    } else {
      proposicoes_va <- proposicoes %>% 
      mutate(tema = map_chr(id_proposicao, fetch_tema_proposicoes_senado)) %>%
      mutate(tema = strsplit(as.character(tema), ";")) %>%
      unnest(tema) %>%
      ungroup() %>%
      rowwise() %>%
      mutate(id_tema = getIdfromListaTema(tema, temas)) %>%
      ungroup() %>%
      mutate(id_proposicao = id_proposicao) %>%
      distinct(id_proposicao, id_tema)
    }
  
  return(proposicoes_va)
}

process_proposicoes_questionario_temas <- function(url = NULL) {
  library(tidyverse)
  
  if(is.null(url)) {
    source(here::here("crawler/proposicoes/utils_proposicoes.R"))
    url <- .URL_PROPOSICOES_VOZATIVA
  }
  
  proposicoes <- read_csv(url, col_types = cols(id_proposicao = "c"))
  
  proposicoes_va <- proposicoes %>% 
    group_by(id_proposicao) %>% 
    mutate(n_prop = row_number()) %>% 
    ungroup() %>% 
    mutate(id_proposicao = if_else(n_prop > 1, paste0(id_proposicao, n_prop), id_proposicao)) %>% 
    select(-n_prop) %>% 
    mutate(tema = strsplit(as.character(tema), ";")) %>% 
    unnest(tema) %>% 
    ungroup() %>% 
    rowwise() %>% 
    mutate(id_tema = getIdfromTema(tema)) %>% 
    ungroup() %>% 
    distinct(id_proposicao, id_tema)
    
  return(proposicoes_va)
}

#' @title Cria dados dos temas
#' @description Cria os dados dos temas
#' @return Dataframe com informações dos temas (descrição e id)
processa_temas_proposicoes <- function() {
  temas <- data.frame(id_tema = c(0, 1, 2, 3, 5, seq(6, 59, 1), 99),
                      tema = c("Meio Ambiente"
                              ,"Direitos Humanos"
                              ,"Integridade e Transparência"
                              ,"Agenda Nacional"
                              ,"Educação"
                              ,"Administração Pública"                                        
                              ,"Direito Penal e Processual Penal"                             
                              ,"Trabalho e Emprego"                                           
                              ,"Processo Legislativo e Atuação Parlamentar"                   
                              ,"Finanças Públicas e Orçamento"                                
                              ,"Economia"                                                     
                              ,"Defesa e Segurança"                                           
                              ,"Relações Internacionais e Comércio Exterior"                  
                              ,"Política,Partidos e Eleições"                                
                              ,"Indústria,Comércio e Serviços"                               
                              ,"Viação,Transporte e Mobilidade"                              
                              ,"Estrutura Fundiária"                                          
                              ,"Meio Ambiente e Desenvolvimento Sustentável"                  
                              ,"Previdência e Assistência Social"                             
                              ,"Direitos Humanos e Minorias"                                  
                              ,"Energia,Recursos Hídricos e Minerais"                        
                              ,"Direito Civil e Processual Civil"                             
                              ,"Saúde"                                                        
                              ,"Comunicações"                                                 
                              ,"Esporte e Lazer"                                              
                              ,"Arte,Cultura e Religião"                                     
                              ,"Direito e Defesa do Consumidor"                               
                              ,"Cidades e Desenvolvimento Urbano"                             
                              ,"Ciência,Tecnologia e Inovação"                                                                           
                              ,"Defesa do Consumidor"                                         
                              ,"Indústria,Comércio e Serviço"                                
                              ,"Servidores Públicos"                                          
                              ,"Planejamento e Orçamento"                                     
                              ,"Direito Eleitoral e Partidos Políticos"                       
                              ,"Tributação"                                                   
                              ,"Administração Pública: Órgãos Públicos"                       
                              ,"Previdência Social"                                           
                              ,"Política Econômica e Sistema Financeiro"                      
                              ,"Processo Legislativo"                                         
                              ,"Segurança Pública"                                            
                              ,"Desenvolvimento Regional"                                     
                              ,"Organização Político-administrativa do Estado"                
                              ,"Família,Proteção a Crianças,Adolescentes,Mulheres e Idosos"
                              ,"Assistência Social"                                           
                              ,"Licitação e Contratos"                                        
                              ,"Desenvolvimento Social e Combate à Fome"                      
                              ,"Política Urbana"                                              
                              ,"Turismo"                                                      
                              ,"Agricultura,Pecuária e Abastecimento"                        
                              ,"Crédito Extraordinário"                                       
                              ,"Arte e Cultura"                                               
                              ,"Recursos Hídricos"                                            
                              ,"Ciência,Tecnologia e Informática"                            
                              ,"Direito Comercial e Econômico"                                
                              ,"Viação e Transportes"                                         
                              ,"Coronavírus (Covid-19)"                                       
                              ,"Desporto e Lazer"                                             
                              ,"Trânsito"                                                     
                              ,"Minas e Energia"
                              ,"Geral"), 
                      slug = c("meio-ambiente"
                               ,"direitos-humanos"
                               ,"integridade-e-transparência"
                               ,"agenda-nacional"
                               ,"educação"
                               ,"administração-pública"
                               ,"direito-penal-e-processual-penal"
                               ,"trabalho-e-emprego"
                               ,"processo-legislativo-e-atuação-parlamentar"
                               ,"finanças-públicas-e-orçamento"
                               ,"economia"
                               ,"defesa-e-segurança"
                               ,"relações-internacionais-e-comércio-exterior"
                               ,"política,partidos-e-eleições"
                               ,"indústria,comércio-e-serviços"
                               ,"viação,transporte-e-mobilidade"
                               ,"estrutura-fundiária"
                               ,"meio-ambiente-e-desenvolvimento-sustentável"
                               ,"previdência-e-assistência-social"
                               ,"direitos-humanos-e-minorias"
                               ,"energia,recursos-hídricos-e-minerais"
                               ,"direito-civil-e-processual-civil"
                               ,"saúde"
                               ,"comunicações"
                               ,"esporte-e-lazer"
                               ,"arte,cultura-e-religião"
                               ,"direito-e-defesa-do-consumidor"
                               ,"cidades-e-desenvolvimento-urbano"
                               ,"ciência,tecnologia-e-inovação"
                               ,"defesa-do-consumidor"
                               ,"indústria,comércio-e-serviço"
                               ,"servidores-públicos"
                               ,"planejamento-e-orçamento"
                               ,"direito-eleitoral-e-partidos-políticos"
                               ,"tributação"
                               ,"administração-pública:-órgãos-públicos"
                               ,"previdência-social"
                               ,"política-econômica-e-sistema-financeiro"
                               ,"processo-legislativo"
                               ,"segurança-pública"
                               ,"desenvolvimento-regional"
                               ,"organização-político-administrativa-do-estado"
                               ,"família,proteção-a-crianças,adolescentes,mulheres-e-idosos"
                               ,"assistência-social"
                               ,"licitação-e-contratos"
                               ,"desenvolvimento-social-e-combate-à-fome"
                               ,"política-urbana"
                               ,"turismo"
                               ,"agricultura,pecuária-e-abastecimento"
                               ,"crédito-extraordinário"
                               ,"arte-e-cultura"
                               ,"recursos-hídricos"
                               ,"ciência,tecnologia-e-informática"
                               ,"direito-comercial-e-econômico"
                               ,"viação-e-transportes"
                               ,"coronavírus-(covid-19)"
                               ,"desporto-e-lazer"
                               ,"trânsito"
                               ,"minas-e-energia"
                               ,"geral"),
                      ativo = c(1, 1, 1, 1, 1, rep(0, 55)),
                      stringsAsFactors = FALSE)
  
  return(temas)
}
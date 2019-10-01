URL <- "https://dadosabertos.camara.leg.br/api/v2/proposicoes/"

fetch_relacionadas <- function(id_prop) {
  print(paste0("Baixando proposições relacionadas a ", id_prop, "..."))
  url <-
    paste0(URL,
           id_prop,
           '/relacionadas')
  
  ids_relacionadas <-
    (RCurl::getURI(url) %>%
       jsonlite::fromJSON())$dados %>%
    as.data.frame() %>% 
    rbind(id_prop) %>% 
    mutate(id_ext = id_prop)
  
  return(ids_relacionadas)
}

get_coautorias <- function(id, autores, parlamentares) {
  if (typeof(id) == 'double') {
    relacionadas <- fetch_relacionadas(id)
    
  } else {
    relacionadas <-
      purrr::map_df(id$id, ~ fetch_relacionadas(.x))
  }
  
  autores <- autores %>% 
    filter(id_req %in% relacionadas$id) %>% 
    distinct() %>% 
    mutate(id_req = as.character(id_req),
           id = as.character(id)) %>% 
    filter(peso_arestas < 1) %>% 
    left_join(relacionadas, by = c("id_req" = "id"))
  
  coautorias <- autores %>%
    full_join(autores, by = c("id_req", "peso_arestas")) %>%
    filter(id.x != id.y)
  
  coautorias <- coautorias %>%
    remove_duplicated_edges() %>%
    mutate(peso_arestas = sum(peso_arestas),
           num_coautorias = n()) %>%
    ungroup() %>%
    mutate(id_req = as.character(id_req))
  
  coautorias <- coautorias %>% 
    inner_join(parlamentares, by = c("id.x" = "id")) %>% 
    inner_join(parlamentares, by = c("id.y" = "id")) %>% 
    select(-c(sg_partido.x, sg_partido.y, id_req)) %>% 
    distinct() %>% 
    select(-id_ext.y) %>% 
    rename(id_ext = id_ext.x)
  
  return(coautorias)
}

prepare_autorias_df_camara <- function(docs_camara, autores_camara) {
  autores_docs <- merge(docs_camara, autores_camara, by = c("id_documento", "casa")) %>%
        dplyr::select(id_principal,
                      casa,
                      id_documento,
                      id_autor)
}

prepare_autorias_df_senado <- function(docs_senado, autores_senado) {
  autores_docs <- merge(docs_senado, autores_senado %>% dplyr::filter(!is.na(id_autor)), 
                        by = c("id_principal", "id_documento", "casa")) %>% 
    dplyr::select(id_principal,
                  casa,
                  id_documento,
                  id_autor)
}

compute_peso_autoria_doc <- function(autorias) {
  peso_autorias <- autorias %>% 
    group_by(id_principal, id_documento) %>% 
    summarise(peso_arestas = 1/n())
}

#' coautorias_2 <-
#'   atores %>% 
#'   filter(id_ext == 14562) 
#' 
#' camara_env <- jsonlite::fromJSON("R/config/environment_camara.json")
#' senado_env <- jsonlite::fromJSON("R/config/environment_senado.json")
#'   
#' documentos_camara <- agoradigital::read_current_docs_camara("data/camara/documentos.csv")
#' documentos_senado <- agoradigital::read_current_docs_senado("data/senado/documentos.csv")
#' autores_camara <- agoradigital::read_current_autores_camara("data/camara/autores.csv")
#' autores_senado <- agoradigital::read_current_autores_senado("data/senado/autores.csv")
#' 
#' #' @title Cria tabela com atores de documentos com seus respectivos tipos de documentos
#' #' @description Retorna um dataframe contendo informações com os autores dos documentos e seus tipos
#' #' @param documentos_df Dataframe dos documentos
#' #' @param autores_df Dataframe com autores dos documentos
#' #' @return Dataframe
#' #' @export
#' create_tabela_atores_camara <- function(documentos_df, autores_df) {
#'   
#'   if (!(agoradigital::check_dataframe(documentos_df)) ||
#'       (!agoradigital::check_dataframe(autores_df))) {
#'     return(tibble::tibble())
#'   }
#'   
#'   autores_docs <- merge(documentos_df, autores_df, by = c("id_documento", "casa")) %>%
#'     dplyr::select(id_principal,
#'                   casa,
#'                   id_documento,
#'                   id_autor,
#'                   nome_autor = nome,
#'                   sigla_tipo,
#'                   partido,
#'                   uf,
#'                   sigla_local = status_proposicao_sigla_orgao,
#'                   descricao_tipo_documento)
#'   
#'   atores_df <- autores_docs %>%
#'     dplyr::mutate(tipo_autor = 'deputado') %>% 
#'     agoradigital::add_tipo_evento_documento() %>%
#'     dplyr::rename(tipo_generico = tipo) %>%
#'     dplyr::group_by(id_ext = id_principal,
#'                     casa,
#'                     id_autor,
#'                     tipo_autor,
#'                     id_documento,
#'                     nome_autor,
#'                     partido,
#'                     uf,
#'                     tipo_generico,
#'                     sigla_local) %>%
#'     dplyr::summarise(qtd_de_documentos = dplyr::n()) %>%
#'     dplyr::arrange(id_ext, -qtd_de_documentos) %>%
#'     dplyr::ungroup()
#'   
#'   atores_df <- .detect_sigla_local(atores_df, camara_env)
#'   
#'   return(atores_df)
#' }
#' 
#' #' @title Cria tabela com atores de documentos com seus respectivos tipos de documentos
#' #' @description Retorna um dataframe contendo informações com os autores dos documentos e seus tipos
#' #' @param documentos_df Dataframe dos documentos
#' #' @param autores_df Dataframe com autores dos documentos
#' #' @return Dataframe
#' #' @export
#' create_tabela_atores_senado <- function(documentos_df, autores_df) {
#'   
#'   if (!(agoradigital::check_dataframe(documentos_df)) ||
#'       (!agoradigital::check_dataframe(autores_df))) {
#'     return(tibble::tibble())
#'   }
#'   
#'   autores_docs <- 
#'     merge(documentos_df, autores_df %>% dplyr::filter(!is.na(id_autor)), by = c("id_principal", "id_documento", "casa")) %>% 
#'     dplyr::mutate(identificacao = descricao_texto) %>% 
#'     dplyr::mutate(identificacao = stringr::str_trim(identificacao)) 
#'   
#'   senado_comissoes <-
#'     senado_env$comissoes_nomes %>% 
#'     tibble::as_tibble() %>% 
#'     dplyr::select(-comissoes_temporarias) %>% 
#'     dplyr::mutate(comissoes_permanentes = paste0("Comissão ", comissoes_permanentes)) %>% 
#'     rbind(list("Plenário", "Plen(á|a)rio")) %>% 
#'     rbind(list("Comissão Especial", "Especial"))
#'   
#'   autores_docs <-
#'     fuzzyjoin::regex_left_join(autores_docs, senado_comissoes, by=c("identificacao_comissao_nome_comissao" = "comissoes_permanentes")) %>% 
#'     dplyr::select(-c(identificacao_comissao_nome_comissao, comissoes_permanentes)) %>% 
#'     dplyr::rename(sigla_local = siglas_comissoes)
#'   
#'   atores_df <- 
#'     autores_docs %>%
#'     dplyr::mutate(nome_autor = 
#'                     stringr::str_replace(nome_autor,
#'                                          "(\\()(.*?)(\\))|(^Deputad(o|a) Federal )|(^Deputad(o|a) )|(^Senador(a)* )|(^Líder do ((.*?)(\\s)))|(^Presidente do Senado Federal: Senador )", ""),
#'                   id_principal = as.numeric(id_principal)) %>%
#'     agoradigital::add_tipo_evento_documento(T) %>% 
#'     dplyr::rename(tipo_generico = tipo) %>%
#'     dplyr::group_by(id_ext = id_principal,
#'                     casa,
#'                     id_autor,
#'                     id_documento,
#'                     tipo_autor,
#'                     nome_autor,
#'                     partido,
#'                     uf,
#'                     tipo_generico,
#'                     sigla_local) %>%
#'     dplyr::summarise(qtd_de_documentos = dplyr::n()) %>%
#'     dplyr::arrange(id_ext, -qtd_de_documentos) %>%
#'     dplyr::ungroup()
#'   
#'   atores_df <- 
#'     .detect_sigla_local(atores_df, senado_env)
#'   
#'   return(atores_df)
#' }
#' 
#' #' @title Detecta comissoes importantes da Camara e Senado
#' #' @description Retorna um dataframe contendo informacoes de importancia de comissoes
#' #' @param atores_df Dataframe dos atores
#' #' @param casa_env Camara ou Senado
#' #' @return Dataframe
#' .detect_sigla_local <- function(atores_df, casa_env) {
#'   atores_df <- atores_df %>%
#'     dplyr::mutate(is_important = dplyr::if_else(is.na(sigla_local),FALSE,
#'                                                 dplyr::if_else((sigla_local %in% c(casa_env$comissoes_nomes$siglas_comissoes) |
#'                                                                   stringr::str_detect(tolower(sigla_local), 'pl') |
#'                                                                   stringr::str_detect(tolower(sigla_local), 'pec') |
#'                                                                   stringr::str_detect(tolower(sigla_local), 'mpv')),TRUE,FALSE)))
#'   
#'   return(atores_df)
#' }
#' 
#' atores_camara <- create_tabela_atores_camara(documentos_camara, autores_camara) %>% mutate(id_documento = as.character(id_documento))
#' atores_senado <- create_tabela_atores_senado(documentos_senado, autores_senado)
#' atores <- bind_rows(atores_camara, atores_senado)
#' 
#' coautores <- atores %>% 
#'   group_by(id_ext, casa, id_documento) %>% 
#'   summarise(autores = paste(id_autor, collapse = ","))

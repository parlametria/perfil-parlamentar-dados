#' @title Baixa nome civil dos deputados
#' @description Baixa nome civil dos deputados pelo id do parlamentar na Câmara.
#' @param id_votacao id do deputado
#' @return Dataframe informações de id e nome civil.
#' @examples
#' deputado <- fetch_deputado(73874)
fetch_deputado <- function(id_deputado) {
  print(paste0("Baixando informações do deputado de id ", id_deputado, "..."))
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados/", id_deputado)
  deputado <- tryCatch({
    data <-  RCurl::getURL(url) %>% 
      jsonlite::fromJSON() %>% 
      unlist() %>% t() %>% 
      as.data.frame() 
    
    if (!"dados.ultimoStatus.situacao" %in% names(data)) {
      data$dados.ultimoStatus.situacao = NA
    }
    
    if (!"dados.escolaridade" %in% names(data)) {
      data$dados.escolaridade = NA
    }
    
    if (!"dados.ultimoStatus.gabinete.email" %in% names(data)) {
      data$dados.ultimoStatus.gabinete.email = NA
    }
    
    data <- data %>% 
      dplyr::bind_cols(
        extract_partido_informations(data$dados.ultimoStatus.uriPartido)) %>% 
      mutate(casa = "camara") %>% 
      select(id = dados.id, 
             casa,
             cpf = dados.cpf,
             nome_civil = dados.nomeCivil,
             nome_eleitoral = dados.ultimoStatus.nomeEleitoral,
             uf = dados.ultimoStatus.siglaUf,
             num_partido,
             sg_partido = dados.ultimoStatus.siglaPartido,
             partido,
             situacao = dados.ultimoStatus.situacao,
             condicao_eleitoral = dados.ultimoStatus.condicaoEleitoral,
             genero = dados.sexo,
             escolaridade = dados.escolaridade,
             email = dados.ultimoStatus.gabinete.email)
    
  }, error = function(e) {
    data <- tribble(~ id, ~ cpf, ~ nome_civil, ~ nome_eleitoral, ~ uf, ~ num_partido,
                    ~ sg_partido, ~ partido, ~ situacao, ~ condicao_eleitoral, ~ genero,
                    ~ grau_instrucao, ~ email)
    return(data)
  })
  
  return(deputado)
}

#' @title Importa dados de todos os deputados de uma legislatura específica
#' @description Importa os dados de todos os deputados federais de uma legislatura específica
#' @return Dataframe contendo informações dos deputados: id, nome civil e cpf
#' @examples
#' deputados <- fetch_deputados(56)
fetch_deputados <- function(legislatura = 56) {
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados?idLegislatura=", legislatura)
  
  ids_deputados <- 
    (RCurl::getURL(url) %>%
       jsonlite::fromJSON())$dados %>% 
    select(id) %>% distinct()
  
  info_pessoais <- do.call("rbind", lapply(ids_deputados$id, 
                                           fetch_deputado))
  return(info_pessoais %>% 
           unique() %>% 
           mutate_if(is.factor, as.character) %>% 
           mutate(id = as.integer(id),
                  legislatura = legislatura))
}

#' @title Extrai informações de um partido a partir de uma URL
#' @description Recebe uma URL da câmara que possui o formato '/partidos/:num e extrai id e nome
#' @param URL no formato "https://dadosabertos.camara.leg.br/api/v2/partidos/:num"
#' @return Dataframe contendo informações de id e nome dos partidos
#' @examples
#' extract_partido_informations("https://dadosabertos.camara.leg.br/api/v2/partidos/36835")
extract_partido_informations <- function(url) {
  partido <- tryCatch({
    data <-  RCurl::getURL(url) %>% 
      jsonlite::fromJSON() %>% 
      unlist() %>% t() %>% 
      as.data.frame() %>% 
      select(num_partido = dados.id, 
             partido = dados.nome)
  }, error = function(e) {
    data <- tribble(
      ~ num_partido, ~ partido)
    return(data)
  })
  
  return (partido)
}

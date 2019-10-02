#' @title Captura informações de deputados integrantes da Mesa na Câmara dos deputados
#' @description Com base na API da Câmara dos Deputados captura informações de deputados integrantes da Mesa
#' @param legislatura Número da legislatura para recuperação dos dados da mesa.
#' @param atual_cargo Flag que indica se deseja obter os deputados atualmente ocupando cargos na mesa. 
#' Se TRUE o parâmetro legislatura será ignorado e a legislatura 56 será usada.
#' @return Dataframe contendo deputados com cargos na Mesa da Câmara. Retorna também as colunas 
#' @examples
#' deputados_mesa <- fetch_cargos_mesa_camara()
fetch_cargos_mesa_camara <- function(legislatura = 56, atual_cargo = TRUE) {
  library(tidyverse)
  
  if (atual_cargo) {
    legislatura = 56
    message("Aviso: parâmetro atual_cargo tem valor TRUE. Valor da legislatura utilizado será 56 (atual).")
  }
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/legislaturas/", legislatura, "/mesa")
  
  dados_raw <- (RCurl::getURL(url) %>% 
    jsonlite::fromJSON())$dados
  
  if (atual_cargo) {
    cargos_mesa <- dados_raw %>% 
      filter(is.na(dataFim)) ## ainda no cargo
  } else {
    cargos_mesa <- dados_raw
  }
  
  cargos_mesa_res <- cargos_mesa %>% 
    mutate(legislatura = legislatura) %>% 
    select(id, nome, sg_partido = siglaPartido, uf = siglaUf, cargo = titulo, 
           data_inicio = dataInicio, data_fim = dataFim, legislatura)
  
  return(cargos_mesa_res)
  
}

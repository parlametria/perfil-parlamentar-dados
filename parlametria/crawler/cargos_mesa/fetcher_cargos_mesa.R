#' @title Captura informações de deputados integrantes da Mesa na Câmara dos deputados
#' @description Com base na API da Câmara dos Deputados captura informações de deputados integrantes da Mesa
#' @param legislatura Número da legislatura para recuperação dos dados da mesa.
#' @param atual_cargo Flag que indica se deseja obter os deputados atualmente ocupando cargos na mesa. 
#' Se TRUE o parâmetro legislatura será ignorado e a legislatura 56 será usada.
#' @return Dataframe contendo deputados com cargos na Mesa da Câmara.
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
           data_inicio = dataInicio, data_fim = dataFim, legislatura) %>% 
    check_cargos()
  
  return(cargos_mesa_res)
  
}

#' @title Captura informações de senadores atualmente integrantes da Mesa no Senado Federal
#' @description Com base na API da Senado captura informações de senadores integrantes da Mesa
#' @return Dataframe contendo senadores com cargos na Mesa do Senado.
#' @examples
#' senadores_mesa <- fetch_cargos_mesa_senado()
fetch_cargos_mesa_senado <- function() {
  library(tidyverse)
  
  url <- "https://legis.senado.leg.br/dadosabertos/dados/MesaSenado.xml"
  
  senadores <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    data <- xml2::xml_find_all(xml, ".//Cargo") %>%
      map_df(function(x) {
        list(
          id = xml2::xml_find_first(x, ".//Http") %>% 
            xml2::xml_text(),
          nome = xml2::xml_find_first(x, ".//NomeParlamentar") %>% 
            xml2::xml_text(),
          bancada = xml2::xml_find_first(x, ".//Bancada") %>% 
            xml2::xml_text(),
          cargo = xml2::xml_find_first(x, ".//Cargo") %>%
            xml2::xml_text()
        )
      }) %>% 
      distinct() %>% 
      mutate(bancada = gsub("[()]", "", bancada)) %>% 
      separate(bancada, into = c("sg_partido", "uf"), sep = "-") %>% 
      filter(!is.na(id)) %>% 
      mutate(data_inicio = NA, data_fim = NA, 
             legislatura = 56, cargo = str_to_title(cargo)) %>% ## Legislatura atual é a 56
      select(id, nome, sg_partido, uf, cargo, data_inicio, data_fim, legislatura) %>% 
      check_cargos()
    
  }, error = function(e) {
    print(e)
    data <- tribble(
      ~ id, ~ nome, ~ sg_partido, ~ uf, ~ cargo,
      ~ data_inicio, ~ data_fim, ~ legislatura)
    return(data)
  })
  
  return(senadores)
}

#' @title Checa se cargos da mesa se encaixam na lista adotada como padrão
#' @description avalia se cargos presentes como coluna em um dataframe se encaixam na lista adotada como padrão.
#' Lança um erro caso seja encontrado um cargo que não se encaixe na lista de cargos possíveis.
#' @param df Dataframe com pelo menos uma coluna chamada cargo
#' @return Dataframe com mesmo conteúdo que o passado como parâmetro.
check_cargos <- function(df) {
  library(tidyverse)
  library(here)
  
  source(here("parlametria/crawler/cargos_mesa/constants.R"))
  
  lista_cargos <- c(.SECRETARIO_1, .SECRETARIO_2, .SECRETARIO_3, .SECRETARIO_4,
                    .VICE_PRESIDENTE_1, .VICE_PRESIDENTE_2, .PRESIDENTE, 
                    .SUPLENTE_SECRETARIO_1, .SUPLENTE_SECRETARIO_2, .SUPLENTE_SECRETARIO_3, .SUPLENTE_SECRETARIO_4,
                    .SUPLENTE_1, .SUPLENTE_2, .SUPLENTE_3, .SUPLENTE_4)
    
  df_check <- df %>% 
    mutate(check = if_else(cargo %in% lista_cargos, TRUE, FALSE))
  
  if(FALSE %in% (df_check %>% pull(check))) {
    stop("Dataframe contém cargo de mesa inválido")
  } else {
    return(df)
  }
}

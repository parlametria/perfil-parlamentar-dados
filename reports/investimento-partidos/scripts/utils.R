#' @title Formata valor para exibição de montante (2500000 para 2.5 milhões)
#' @description Formata valor para exibição de montante (2500000 para 2.5 milhões)
#' @param tx Número para ser formatado
#' @return String com número formatado
#' @examples
#' format_currency(2500000)
format_currency <- function(tx) { 
  div <- findInterval(as.numeric(gsub("\\,", "", tx)), 
                      c(0, 1e3, 1e6, 1e9) )
  paste(round(as.numeric(gsub("\\,", "", tx))/10^(3*(div-1)), 2), 
        c("", "mil", "milhões", "bilhões")[div] )
}

#' @title Formata valor para exibição de montante (2500000 para 2.5 M)
#' @description Formata valor para exibição de montante (2500000 para 2.5 M)
#' @param tx Número para ser formatado
#' @return String com número formatado
#' @examples
#' format_currency_value(2500000)
format_currency_value <- function(tx) { 
  div <- findInterval(as.numeric(gsub("\\,", "", tx)), 
                      c(0, 1e3, 1e6, 1e9) )
  paste(round(as.numeric(gsub("\\,", "", tx))/10^(3*(div-1)), 2), 
        c("", "k", "M", "B")[div] )
}

#' @title Remove acentuação e torna a string composta apenas por letras minúsculas
#' @description Remove acentuação e torna tudo minúsculo
#' @param word String para ser formatada
#' @return String padronizada
#' @examples
#' format_string("Eu Não sei o que aconteceu") ## eu nao sei o que aconteceu
format_string <- function(word) {
  return(tolower(iconv(word, from="UTF-8", to="ASCII//TRANSLIT")))
}

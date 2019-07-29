format_currency <- function(tx) { 
  div <- findInterval(as.numeric(gsub("\\,", "", tx)), 
                      c(0, 1e3, 1e6, 1e9) )
  paste(round(as.numeric(gsub("\\,", "", tx))/10^(3*(div-1)), 2), 
        c("", "mil", "milhões", "bilhões")[div] )
}

format_currency_value <- function(tx) { 
  div <- findInterval(as.numeric(gsub("\\,", "", tx)), 
                      c(0, 1e3, 1e6, 1e9) )
  paste(round(as.numeric(gsub("\\,", "", tx))/10^(3*(div-1)), 2), 
        c("", "k", "M", "B")[div] )
}
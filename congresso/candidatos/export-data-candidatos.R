suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(here)))
suppressWarnings(suppressMessages(source(here::here("congresso/candidatos/tidy-data-candidatos.R"))))

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório!\n")
message("Iniciando processamento...")

if (length(args) == 0){
  anos <- c(2010, 2014, 2018)
  message("Considerando os anos de 2010, 2014 e 2018")
  
  cargos <- c(6)
  message("Considerando o cargo 6 - DEPUTADO FEDERAL")
  
  saida <- "./output_candidatos.csv"
  message("Salvando o resultado em ./output_candidatos.csv")
} else if (length(args) == 1) {
  anos <- suppressMessages(read_csv(args[1])) %>% pull(ano)
  message(paste0("Lendo os anos do arquivo ", args[1]))
  
  cargos <- c(6)
  message("Considerando o cargo 6 - DEPUTADO FEDERAL")
  
  saida <- "./output_candidatos.csv"
  message("Salvando o resultado em ./output_candidatos.csv")
} else if (length(args) == 2) {
  anos <- suppressMessages(read_csv(args[1])) %>% pull(ano)
  message(paste0("Lendo os anos do arquivo ", args[1]))
  
  cargos <- suppressMessages(read_csv(args[2])) %>% pull(cargo)
  message(paste0("Lendo os cargos do arquivo ", args[2]))
  
  saida <- "./output_candidatos.csv"
  message("Salvando o resultado em ./output_candidatos.csv")
} else {
  anos <- suppressMessages(read_csv(args[1])) %>% pull(ano)
  message(paste0("Lendo os anos do arquivo ", args[1]))
  
  cargos <- suppressMessages(read_csv(args[2])) %>% pull(cargo)
  message(paste0("Lendo os cargos do arquivo ", args[2]))
  
  saida <- args[3]
  message(paste0("Salvando o resultado em ", args[3]))
}

candidatos <- processa_dados_candidatos(c(anos), c(cargos))

write.csv(candidatos, saida, row.names = FALSE)

message("Concluído!")
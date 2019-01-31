suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(here)))
suppressWarnings(suppressMessages(source(here::here("congresso/candidatos/tidy-data-candidatos.R"))))
if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-a", "--anos"), type="character", default="DEFAULT_OPT", 
              help="caminho para o arquivo contendo os anos das eleições [default= c(2010, 2014, 2018)]", metavar="character"),
  make_option(c("-c", "--cargos"), type="character", default="DEFAULT_OPT", 
              help="caminho para o arquivo contendo os cargos para filtrar [default= 6]. 6 é o código para Deputado Federal", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="output_candidatos.csv", 
              help="nome do arquivo de saída [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (opt$anos == "DEFAULT_OPT") {
  anos <- c(2010, 2014, 2018)
} else {
  anos <- suppressMessages(readr::read_csv(opt$anos)) %>% pull(ano)
}

if (opt$cargos == "DEFAULT_OPT") {
  cargos <- c(6)
} else {
  cargos <- suppressMessages(readr::read_csv(opt$cargos)) %>% pull(cargo)
}

saida <- opt$out

message("Iniciando processamento...")
candidatos <- processa_dados_candidatos(c(anos), c(cargos))

message(paste0("Salvando o resultado em ", saida))
write.csv(candidatos, saida, row.names = FALSE)

message("Concluído!")
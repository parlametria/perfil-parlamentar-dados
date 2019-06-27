library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/partidos/analyzer_partidos.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/partidos.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character"),
  make_option(c("-l", "--leg"), type="character", default="56", 
              help="id de legislatura [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

legislatura <- opt$leg
saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")
parlamentares <- process_partidos_por_leg(legislatura)

message(paste0("Salvando o resultado em ", saida))
write.csv(parlamentares, saida, row.names = FALSE)

message("Concluído!")
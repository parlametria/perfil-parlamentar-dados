library(tidyverse)
library(here)
source(here::here("parlametria/crawler/articulacoes/analyzer_coautorias.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/articulacoes/articulacoes_tereza_cristina.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")
articulacoes_tereza_cristina <- coautorias_by_parlamentar(178901)

message(paste0("Salvando o resultado em ", saida))
write_csv(articulacoes_tereza_cristina, saida)

message("Concluído!")
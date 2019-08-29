library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/patrimonio/propriedades-rurais/analyzer_propriedades_rurais.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/propriedades_rurais.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
message("Processando dados de propriedades rurais dos deputados...")
propriedades_rurais <- process_deputados_propriedades_rurais()

message(paste0("Salvando o resultado em ", saida))
readr::write_csv(propriedades_rurais, saida)

message("Concluído!")

library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/resumo/analyzer_resumo_parlamentares.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/resumo_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
resumo <- process_resumo_deputados()

message(paste0("Salvando o resultado em ", saida))
readr::write_csv(resumo, saida)

message("Concluído!")

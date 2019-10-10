library(tidyverse)
library(here)
source(here::here("parlametria/crawler/resumo/cargos_resumo/analyzer_cargos_resumo.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")

option_list = list(
  make_option(c("-oa", "--out"), type="character", default=here::here("parlametria/raw_data/resumo/parlamentares_cargos.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida_cargos <- opt$out

message("Iniciando processamento...")
cargos <- process_cargos_resumo_parlamentares()

message(paste0("Salvando o resultado de cargos e lideranças em ", saida_cargos))
readr::write_csv(cargos, saida_cargos)

message("Concluído!")

library(tidyverse)
library(here)
source(here::here("parlametria/crawler/resumo/aderencia/analyzer_aderencia.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/resumo/parlamentares_aderencia.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida_aderencia <- opt$out

message("Iniciando processamento...")
aderencia <- process_aderencia_meio_ambiente()

message(paste0("Salvando o resultado de aderência em ", saida_aderencia))
readr::write_csv(aderencia, saida_aderencia)

message("Concluído!")

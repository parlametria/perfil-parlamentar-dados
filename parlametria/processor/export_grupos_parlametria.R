library(tidyverse)
library(here)
source(here::here("parlametria/processor/processor_grupos_parlametria.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/grupos_parlametria/grupos_parlamentares_parlametria.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Processando dados para os grupos do parlametria...")

grupos_parlamentares_parlametria <- agrupa_parlamentares_parlametria()

message(paste0("Salvando o resultado em ", saida))
readr::write_csv(grupos_parlamentares_parlametria, saida)

message("Concluído!")

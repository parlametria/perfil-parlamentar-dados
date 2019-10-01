library(tidyverse)
library(here)
source(here::here("parlametria/crawler/discursos_rac/fetcher_discursos_rac.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/discursos_rac/discursos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")
discurso_parlamentares <- fetch_analise_discursos_rac()

message(paste0("Salvando o resultado em ", saida))
write_csv(discurso_parlamentares, saida)

message("Concluído!")
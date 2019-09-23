library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/frentes/fetcher_frentes.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-ocom", "--outFrentes"), type="character", default=here::here("crawler/raw_data/frentes/frentes.csv"),
              help="nome do arquivo de saída para as informações das frentes [default= %default]", metavar="character"),
  
  make_option(c("-oc", "--outMembros"), type="character", default=here::here("crawler/raw_data/frentes/membros_frentes.csv"),
              help="nome do arquivo de saída para as informações de membros das frentes [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_frentes = opt$outFrentes
output_membros <- opt$outMembros

message("Iniciando processamento...")
dados_frentes <- processa_frentes_membros()

frentes <- dados_frentes[[1]]

membros <- dados_frentes[[2]]

message(paste0("Salvando o resultado de frentes em: ", output_frentes))
readr::write_csv(frentes, output_frentes)
message(paste0("Salvando o resultado da membros das frentes em: ", output_membros))
readr::write_csv(membros, output_membros)

message("Concluído!")

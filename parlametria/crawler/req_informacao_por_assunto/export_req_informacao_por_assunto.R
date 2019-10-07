library(tidyverse)
library(here)
source(here::here("parlametria/crawler/req_informacao_por_assunto/fetcher_req_informacao_por_assunto.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/autorias/req_info_meio_ambiente_agricultura.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")
req_info_por_assunto <- fetch_req_informacao_ambiente_agricultura()

message(paste0("Salvando o resultado em ", saida))
write_csv(req_info_por_assunto, saida)

message("Concluído!")
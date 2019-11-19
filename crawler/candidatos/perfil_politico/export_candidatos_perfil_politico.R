library(tidyverse)
library(here)
source(here::here("crawler/candidatos/perfil_politico/fetcher_info_candidatos_perfil_politico.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/candidatos_perfil_politico.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
candidatos <- fetch_ids_perfil_politico()

message(paste0("Salvando o resultado em ", saida))
write.csv(candidatos, saida, row.names = FALSE)

message("Concluído!")

library(tidyverse)
source(here::here("crawler/parlamentares/liderancas/fetcher_liderancas.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--output"), type="character", default="../../raw_data/liderancas.csv",
              help="nome do arquivo de saída para as informações de lideranças [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_path = opt$output

message("Iniciando processamento...")

liderancas <- fetch_liderancas_camara()

message(paste0("Salvando o resultado das lideranças em: ", output_path))

readr::write_csv(liderancas, output_path)

message("Concluído!")

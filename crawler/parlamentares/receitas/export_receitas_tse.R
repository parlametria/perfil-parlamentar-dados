library(tidyverse)

source(here::here("crawler/parlamentares/receitas/analyzer_receitas_tse.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/receitas_tse_2018.csv"),
              help="nome do arquivo de saída para as informações de receitas dos parlamentares [default= %default]", 
              metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output <- opt$out

message("Iniciando processamento...")
dados_receitas <- processa_doacoes_partidarias_tse()

message(paste0("Salvando o resultado de receitas em: ", output))
readr::write_csv(dados_receitas, output)

message("Concluído!")

library(tidyverse)

source(here::here("parlametria/crawler/receitas/analyzer_receitas_tse.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-a", "--ano"), type="character", default="2018",
              help="Ano de declaração para dados de doadores [default= %default]",
              metavar="character"),
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/receitas/parlamentares_doadores.csv"),
              help="nome do arquivo de saída para as informações de receitas dos parlamentares [default= %default]", 
              metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output <- opt$out
ano <- opt$ano %>% as.numeric()

message("Iniciando processamento...")
dados_receitas <- processa_doacoes_parlamentares_tse(ano)

message(paste0("Salvando o resultado de receitas em: ", output))
readr::write_csv(dados_receitas, output)

message("Concluído!")

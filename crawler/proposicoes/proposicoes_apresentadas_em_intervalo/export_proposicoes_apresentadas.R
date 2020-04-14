library(tidyverse)
source(here::here("crawler/proposicoes/proposicoes_apresentadas_em_intervalo/analyzer_proposicoes_apresentadas.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--output"), type="character", default=here::here("crawler/raw_data/proposicoes_apresentadas.csv"),
              help="nome do arquivo de saída para as informações das proposições apresentadas [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_path = opt$output

message("Iniciando processamento...")

hoje <- Sys.Date()
proposicoes <- process_props_apresentadas_intervalo(data_inicial = "2020-03-11", data_final = hoje)

message(paste0("Salvando o resultado dos metadados das proposições em: ", output_path))

readr::write_csv(proposicoes, output_path)

message("Concluído!")

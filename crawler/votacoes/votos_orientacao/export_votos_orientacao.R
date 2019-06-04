library(tidyverse)
library(here)
source(here("crawler/votacoes/votos_orientacao/analyzer_votos_orientacao.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-a", "--ano"), type="character", default=2019,
              help="Ano para ocorrência das votações em plenário [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

ano = opt$ano

message("Iniciando processamento...")
votos_orientacao <- process_votos_orientacao(ano)

message(paste0("Salvando o resultado em ", here(paste0("crawler/raw_data/votos_", ano))))
write_csv(votos_orientacao[[1]], here(paste0("crawler/raw_data/votos_", ano, ".csv")))

message(paste0("Salvando o resultado em ", here(paste0("crawler/raw_data/orientacoes_", ano))))
write_csv(votos_orientacao[[2]], here(paste0("crawler/raw_data/orientacoes_", ano, ".csv")))

message("Concluído!")
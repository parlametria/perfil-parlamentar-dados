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
  
  make_option(c("-a", "--ano"), type="character", default="2019,2020,2021,2022",
              help="Ano para ocorrência das votações em plenário [default= %default]. 
              Use vírgulas para separar se houver mais de um valor", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

ano = opt$ano

message("Iniciando processamento...")

anos <- strsplit(ano, split=",") %>% unlist()

votos_orientacao <- process_votos_orientacao_anos_url(anos)

message(paste0("Salvando o resultado em ", here("crawler/raw_data/votos.csv")))
write_csv(votos_orientacao[[1]], here("crawler/raw_data/votos.csv"))

message(paste0("Salvando o resultado em ", here("crawler/raw_data/orientacoes.csv")))
write_csv(votos_orientacao[[2]], here("crawler/raw_data/orientacoes.csv"))

message("Concluído!")
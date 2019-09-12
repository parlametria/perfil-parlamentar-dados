library(tidyverse)
source(here::here("crawler/parlamentares/score_ruralistas/analyzer_score_ambientalista.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--output"), type="character", default=here::here("crawler/raw_data/indice_vinculo_economico_agro.csv"),
              help="nome do arquivo de saída com o índice de vínculo econômico [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_path = opt$output

options(scipen = 999)

message("Iniciando processamento...")

indice_vinculo_economico <- processa_indice_vinculo_economico()

message(paste0("Salvando o resultado em: ", output_path))

write.csv(indice_vinculo_economico, output_path)

message("Concluído!")

library(tidyverse)
library(here)
source(here::here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_agricolas_parlamentares.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/empresas/socios_empresas_agricolas_todos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")
socios_empresas_agricolas_todos_parlamentares <- process_socios_empresas_agricolas_parlamentares()

message(paste0("Salvando o resultado em ", saida))
write_csv(socios_empresas_agricolas_todos_parlamentares[[1]], saida)

message("Concluído!")
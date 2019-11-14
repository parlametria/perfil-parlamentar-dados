library(tidyverse)
library(here)
source(here::here("parlametria/crawler/empresas/socios_empresas/parlamentares/analyzer_socios_empresas_parlamentares.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--o"), type="character", default=here::here("parlametria/raw_data/empresas/socios_empresas_todos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character"),
  make_option(c("-s", "--s"), type="character", default=here::here("parlametria/raw_data/empresas/info_empresas_socios_todos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida_socio <- opt$o
saida_info <- opt$s

message("Iniciando processamento...")
message("Baixando dados...")
socios_empresas_todos_parlamentares <- process_socios_empresas_parlamentares(somente_agricolas = FALSE)

message("Salvando o resultado...")
write_csv(socios_empresas_todos_parlamentares[[1]], saida_socio)
write_csv(socios_empresas_todos_parlamentares[[2]], saida_info)

message("Concluído!")
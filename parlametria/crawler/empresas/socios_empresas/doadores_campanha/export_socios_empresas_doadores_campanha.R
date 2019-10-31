library(tidyverse)
library(here)
source(here::here("parlametria/crawler/empresas/socios_empresas/doadores_campanha/analyzer_socios_empresas_doadores_campanha.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--o"), type="character", default=here::here("parlametria/raw_data/empresas/empresas_doadores_todos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character"),
  make_option(c("-s", "--s"), type="character", default=here::here("parlametria/raw_data/empresas/info_empresas_doadores_todos_parlamentares.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida_socios_empresas <- opt$o
saida_info_empresas <- opt$s

message("Iniciando processamento...")
message("Baixando dados...")
socios_empresas_todos_doadores <- processa_empresas_doadores(fragmentado = TRUE)

message(paste0("Salvando o resultado..."))
write_csv(socios_empresas_todos_doadores[[1]], saida_socios_empresas)
write_csv(socios_empresas_todos_doadores[[2]], saida_info_empresas)

message("Concluído!")
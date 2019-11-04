library(tidyverse)
library(here)
source(here::here("parlametria/processor/processor_grupos_parlametria.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/dados_perfil_mais.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Processando dados para o perfil mais...")

dados_perfil_mais <- process_indices_parlametria()

message(paste0("Salvando o resultado em ", saida))
readr::write_csv(dados_perfil_mais, saida)

message("Concluído!")

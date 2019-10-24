library(tidyverse)
library(here)
source(here::here("parlametria/crawler/resumo/investimento_partidario/analyzer_investimento_partidario.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("parlametria/raw_data/resumo/parlamentares_investimento.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

message("Iniciando processamento...")
investimento <- process_investimento_partidario(filtrar_em_exercicio = FALSE)

message(paste0("Salvando o resultado de investimento em ", saida))
write.csv(investimento, saida, row.names = FALSE, quote = FALSE)

message("Concluído!")

library(tidyverse)
library(here)
source(here::here("crawler/votacoes/comissoes/fetcher_votacoes_comissoes.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-i", "--input"), type="character", default=here::here("crawler/raw_data/parlamentares.csv"), 
              help="nome do arquivo de entrada [default= %default]", metavar="character"),
  
  make_option(c("-y", "--year"), type="character", default="2019", 
              help="ano das votacoes [default= %default]", metavar="character"),
  
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/votacoes_comissoes.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

df_parlamentares <- opt$input
ano = opt$year
saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados de votações de comissões...")
mandatos <- fetch_all_votacoes_por_ano(df_parlamentares,
                                 ano)

message(paste0("Salvando o resultado em ", saida))
readr::write_csv(mandatos, saida)

message("Concluído!")

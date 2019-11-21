library(tidyverse)
library(here)
source(here::here("parlametria/processor/empresas/processor_info_relatorio_fabio.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out1"), type="character", default=here::here("parlametria/raw_data/empresas/parlamentares_ligacao_atividade_economica.csv"), 
              help="nome do arquivo de saída para o dataframe de ligações econômicas [default= %default]", metavar="character"),
  make_option(c("-i", "--out2"), type="character", default=here::here("parlametria/raw_data/empresas/parlamentares_socios_empresas.csv"), 
              help="nome do arquivo de saída para o dataframe de parlamentares sócios de empresas [default= %default]", metavar="character"),
  make_option(c("-u", "--out3"), type="character", default=here::here("parlametria/raw_data/empresas/doadores_socios_empresas.csv"), 
              help="nome do arquivo de saída para o dataframe de doadores sócios de empresas [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida1 <- opt$out1
saida2 <- opt$out2
saida3 <- opt$out3

message("Iniciando processamento...")
ligacoes <- processa_indice_geral_ligacao_economica()
parlamentares_socios <- processa_atividades_economicas_empresas()
doadores_socios <- processa_atividades_economicas_empresas_doadores()
  
message(paste0("Salvando o resultado em ", saida1))
write_csv(ligacoes, saida1)

message(paste0("Salvando o resultado em ", saida2))
write_csv(parlamentares_socios, saida2)

message(paste0("Salvando o resultado em ", saida3))
write_csv(doadores_socios, saida3)

message("Concluído!")

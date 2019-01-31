suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(rcongresso)))
suppressWarnings(suppressMessages(library(here)))
suppressWarnings(suppressMessages(library(tm)))
suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/analyzer_votos.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-c", "--candidatos"), type="character", default="../raw_data/candidatos_tse_10_18.csv",
              help="caminho para o arquivo csv contendo os dados dos candidatos  [default= %default]", metavar="character"),

  make_option(c("-v", "--votacoes"), type="character", default="../raw_data/tabela_votacoes.csv",
              help="caminho para o arquivo csv contendo os dados das votações [default= %default]", metavar="character"),

  make_option(c("-o", "--out"), type="character", default="../raw_data/votacoes.csv",
              help="nome do arquivo de saída [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

candidatos_datapath = opt$candidatos
votacoes_datapath = opt$votacoes
output_datapath <- opt$out

message("Iniciando processamento...")
votacoes <- processa_votos(candidatos_datapath, votacoes_datapath)

message(paste0("Salvando o resultado em ", output_datapath))
write.csv(votacoes, output_datapath, row.names = FALSE)

message("Concluído!")

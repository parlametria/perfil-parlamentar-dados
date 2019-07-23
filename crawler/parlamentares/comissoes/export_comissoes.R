library(tidyverse)
#devtools::install_github('analytics-ufcg/leggoR', force = T)
library(agoradigital)
#devtools::install_github('analytics-ufcg/rcongresso', force = T)
library(rcongresso)

source(here::here("crawler/parlamentares/comissoes/analyzer_comissoes.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-ocom", "--outComposicoes"), type="character", default=here::here("crawler/raw_data/composicao_comissoes.csv"),
              help="nome do arquivo de saída para as informações de composição de comissões [default= %default]", metavar="character"),
  
  make_option(c("-oc", "--outComissoes"), type="character", default=here::here("crawler/raw_data/comissoes.csv"),
              help="nome do arquivo de saída para as informações de comissões [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_composicao_comissoes = opt$outComposicoes
output_comissoes <- opt$outComissoes

message("Iniciando processamento...")
dados_comissoes <- processa_comissoes_composicao()

comissoes <- dados_comissoes[[1]]

composicao_comissoes <- dados_comissoes[[2]]

message(paste0("Salvando o resultado de comissões em: ", output_comissoes))
readr::write_csv(comissoes, output_comissoes)
message(paste0("Salvando o resultado da composição das comissões em: ", output_composicao_comissoes))
readr::write_csv(composicao_comissoes, output_composicao_comissoes)

message("Concluído!")

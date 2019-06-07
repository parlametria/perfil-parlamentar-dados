library(tidyverse)
library(here)

if(!require(optparse)){
  install.packages("optparse")
  library(optparse)
}

message("Leia o README deste diretório")
message("Use --help para mais informações\n")

option_list <- list(
  make_option(c("-o", "--output"), 
              type="character", 
              default="./data/", 
              help="diretório de saída [default= %default]", 
              metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)

opt <- parse_args(opt_parser)

output <- opt$output

source(here::here("bd/analyzer_data_bd.R"))

message("Processando dados...")
parlamentares <- processa_parlamentares()
perguntas <- processa_perguntas()
proposicoes <- processa_proposicoes()
respostas <- processa_respostas()
temas <- processa_temas()
votacoes <- processa_votacoes()
comissoes <- processa_comissoes()
composicao_comissoes <- processa_composicao_comissoes()
mandatos <- processa_mandatos()
liderancas <- processa_liderancas()

message("Escrevendo dados em csv...")
write_csv(parlamentares, paste0(output, "parlamentares.csv"))
write_csv(perguntas, paste0(output, "perguntas.csv"))
write_csv(proposicoes, paste0(output, "proposicoes.csv"))
write_csv(respostas, paste0(output, "respostas.csv"))
write_csv(temas, paste0(output, "temas.csv"))
write_csv(votacoes, paste0(output, "votacoes.csv"))
write_csv(comissoes, paste0(output, "comissoes.csv"))
write_csv(composicao_comissoes, paste0(output, "composicao_comissoes.csv"))
write_csv(mandatos, paste0(output, "mandatos.csv"))
write_csv(liderancas, paste0(output, "liderancas.csv"))
message("Concluído")

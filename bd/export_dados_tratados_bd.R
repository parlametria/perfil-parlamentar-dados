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
candidatos <- processa_candidatos()
perguntas <- processa_perguntas()
proposicoes <- processa_proposicoes()
respostas <- processa_respostas()
temas <- processa_temas()
votacoes <- processa_votacoes()
composicao_comissoes <- processa_composicao_comissoes()

message("Escrevendo dados em csv...")
write.csv(candidatos, paste0(output, "candidatos.csv"), row.names = FALSE)
write.csv(perguntas, paste0(output, "perguntas.csv"), row.names = FALSE)
write.csv(proposicoes, paste0(output, "proposicoes.csv"), row.names = FALSE)
write.csv(respostas, paste0(output, "respostas.csv"), row.names = FALSE)
write.csv(temas, paste0(output, "temas.csv"), row.names = FALSE)
write.csv(votacoes, paste0(output, "votacoes.csv"), row.names = FALSE)
write.csv(composicao_comissoes, paste0(output, "composicao_comissoes.csv"), row.names = FALSE)

message("Concluído")

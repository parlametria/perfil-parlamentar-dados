suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/analyzer_votos.R"))))
  
if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

if(!require(devtools)){
  install.packages("devtools")
}

suppressWarnings(suppressMessages(devtools::install_github('analytics-ufcg/rcongresso', force = T)))

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(

  make_option(c("-v", "--votacoes"), type="character", default="../raw_data/tabela_votacoes.csv",
              help="caminho para o arquivo csv contendo os dados das votações [default= %default]", metavar="character"),

  make_option(c("-o", "--out"), type="character", default="../raw_data/votacoes.csv",
              help="nome do arquivo de saída [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

votacoes_datapath = opt$votacoes
output_datapath <- opt$out

message("Iniciando processamento...")
votacoes <- processa_votos(votacoes_datapath)

message(paste0("Salvando o resultado em ", output_datapath))
write.csv(votacoes, output_datapath, row.names = FALSE)

message("Concluído!")

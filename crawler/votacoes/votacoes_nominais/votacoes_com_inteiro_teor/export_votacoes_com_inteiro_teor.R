suppressWarnings(suppressMessages(
source(here::here("crawler/votacoes/votacoes_nominais/votacoes_com_inteiro_teor/analyzer_votacoes_com_inteiro_teor.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-i", "--iniyear"), type="character", default="2015",
              help="ano inicial das votações [default= %default]", metavar="character"),
  
  make_option(c("-e", "--endyear"), type="character", default="2019",
              help="ano final das votações [default= %default]", metavar="character"),
  
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/votacoes_nominais_15_a_19.csv"),
              help="nome do arquivo de saída [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_datapath <- opt$out
ano_inicial <- opt$iniyear
ano_final <- opt$endyear

message("Iniciando processamento...")
votacoes <- export_votacoes_nominais(ano_inicial, ano_final, output_datapath)

message(paste0("Salvando o resultado em ", output_datapath))
write.csv(votacoes, output_datapath, row.names = FALSE)

message("Concluído!")
suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/votacoes_nominais/analyzer_votacoes_info.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/votacoes_info.csv"),
              help="nome do arquivo de saída [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

votacoes_datapath = opt$votacoes
output_datapath <- opt$out

message("Iniciando processamento...")
votacoes <- processa_votacoes_info()

message(paste0("Salvando o resultado em ", output_datapath))
write.csv(votacoes, output_datapath, row.names = FALSE)

message("Concluído!")

source(here::here("parlametria/crawler/cargos_mesa/analyzer_cargos_mesa.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-o", "--outCargosMesa"), type="character", default=here::here("crawler/raw_data/cargos_mesa.csv"),
              help="nome do arquivo de saída para as informações de cargos em mesa diretora [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_cargos_mesa = opt$outCargosMesa

message("Iniciando processamento...")

dados_cargos_mesa <- processa_cargos_mesa()

message(paste0("Salvando o resultado de cargos de mesa em: ", output_cargos_mesa))
readr::write_csv(dados_cargos_mesa, output_cargos_mesa)

message("Concluído!")

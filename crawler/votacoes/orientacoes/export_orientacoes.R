suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/orientacoes/analyzer_orientacoes.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/orientacoes.csv"),
              help="nome do arquivo de saída [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_datapath <- opt$out

message("Iniciando processamento...")
orientacoes <- process_orientacao_anos_url_camara()
 # rbind(process_orientacao_anos_url_camara(),
 #                    process_orientacao_senado())

message(paste0("Salvando o resultado em ", output_datapath))
readr::write_csv(orientacoes, output_datapath)

message("Concluído!")
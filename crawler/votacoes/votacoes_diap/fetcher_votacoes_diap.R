suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(XML)))
suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/votacoes_diap/analyzer_xml_diap.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-v", "--votacoes"), type="character", default="./mapa_votacoes_2015_2019.xml", 
              help="caminho para o arquivo xml contendo os dados das votações fornecidos pelo diap. [default= %default]", metavar="character"),
  
  make_option(c("-o", "--out"), type="character", default="./votacoes_diap.csv", 
              help="nome do arquivo de saída [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

votacoes_datapath = opt$votacoes
output_datapath <- opt$out

message("Iniciando processamento...")
xml <- xmlParse(votacoes_datapath)
xmltop = xmlRoot(xml)

# 50 a 88 são páginas referentes aos dados das votações
paginas <- seq(50, 88)
votacoes <- do.call("rbind", lapply(paginas, votacoes_por_pagina)) 

message("Baixando detalhes das votações, isto pode demorar um pouco...")
votacoes_detalhadas <-  processa_votacoes_detalhes(votacoes)
  
message("Concluído!")
message(paste0("Salvando o resultado em ", output_datapath))
write.csv(votacoes_detalhadas, output_datapath, row.names = FALSE)

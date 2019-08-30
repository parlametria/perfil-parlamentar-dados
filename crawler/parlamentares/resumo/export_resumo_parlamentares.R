library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/resumo/analyzer_resumo_parlamentares.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/parlamentares_investimento.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character"),
  make_option(c("-oa", "--outaderencia"), type="character", default=here::here("crawler/raw_data/parlamentares_aderencia.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

saida <- opt$out

saida_aderencia <- opt$outaderencia

message("Iniciando processamento...")
investimento <- process_resumo_deputados_investimento()
aderencia <- process_resumo_deputados_aderencia()

message(paste0("Salvando o resultado de investimento em ", saida))
readr::write_csv(investimento, saida)

message(paste0("Salvando o resultado de aderência em ", saida_aderencia))
readr::write_csv(aderencia, saida_aderencia)

message("Concluído!")

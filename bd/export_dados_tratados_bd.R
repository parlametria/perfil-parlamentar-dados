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
              default=here::here("bd/data/"), 	
              help="diretório de saída [default= %default]", 	
              metavar="character")	
)	

 opt_parser <- OptionParser(option_list=option_list)	

 opt <- parse_args(opt_parser)	

 output <- opt$output	
 
 library(here)

message("Processando dados...")	
# parlamentares <- processa_parlamentares()	
# perguntas <- processa_perguntas()	
# proposicoes <- processa_proposicoes()	
# proposicoes_temas <- processa_proposicoes_temas()
# respostas <- processa_respostas()
# temas <- processa_temas()
# votos <- processa_votos()

source(here("bd/processor/votacoes/processa_votacoes.R"))
votacoes <- processa_votacoes()

source(here("bd/processor/orientacoes/processa_orientacoes.R"))
orientacoes <- processa_orientacoes()

source(here("bd/processor/comissoes/processa_comissoes.R"))
comissoes <- processa_comissoes()

source(here("bd/processor/comissoes/processa_composicao_comissoes.R"))
composicao_comissoes <- processa_composicao_comissoes()

source(here("bd/processor/mandatos/processa_mandatos.R"))
mandatos <- processa_mandatos()

source(here("bd/processor/liderancas/processa_liderancas.R"))
liderancas <- processa_liderancas()

source(here("bd/processor/aderencia/processa_aderencia.R"))
aderencia <- processa_aderencia()

source(here("bd/processor/partidos/processa_partidos.R"))
partidos <- processa_partidos()

message("Escrevendo dados em csv...")	
# write_csv(parlamentares, paste0(output, "parlamentares.csv"))	
# write_csv(perguntas, paste0(output, "perguntas.csv"))	
# write_csv(proposicoes, paste0(output, "proposicoes.csv"))	
# write_csv(proposicoes_temas, paste0(output, "proposicoes_temas.csv"))	
# write_csv(respostas, paste0(output, "respostas.csv"))
# write_csv(temas, paste0(output, "temas.csv"))
# write_csv(votos, paste0(output, "votos.csv"))
write_csv(votacoes, paste0(output, "votacoes.csv"))
write_csv(orientacoes, paste0(output, "orientacoes.csv"))
write_csv(comissoes, paste0(output, "comissoes.csv"))
write_csv(composicao_comissoes, paste0(output, "composicao_comissoes.csv"))
write_csv(mandatos, paste0(output, "mandatos.csv"))
write_csv(liderancas, paste0(output, "liderancas.csv"))
write_csv(aderencia, paste0(output, "aderencia.csv"))
write_csv(partidos, paste0(output, "partidos.csv"))
message("Concluído")
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

message("Processando dados...")	

source(here("bd/processor/parlamentares/processa_parlamentares.R"))
parlamentares <- processa_parlamentares()

source(here("bd/processor/perguntas/processa_perguntas.R"))
perguntas <- processa_perguntas()

source(here("bd/processor/proposicoes/processa_proposicoes.R"))
proposicoes <- processa_proposicoes()

source(here("bd/processor/proposicoes/processa_proposicoes_temas.R"))
proposicoes_temas <- processa_proposicoes_temas()

source(here("bd/processor/respostas/processa_respostas.R"))
respostas <- processa_respostas()

source(here("bd/processor/temas/processa_temas.R"))
temas <- processa_temas()

source(here("bd/processor/votos/processa_votos.R"))
votos <- processa_votos()

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

source(here("bd/processor/investimento_partidario/processa_investimento_partidario_parlamentar.R"))
investimento_partidario_parlamentar <-  processa_investimento_partidario_parlamentar()

source(here("bd/processor/investimento_partidario/processa_investimento_partidario.R"))
investimento_partidario <- processa_investimento_partidario()

source(here("bd/processor/perfil_mais/processa_perfil_mais.R"))
perfil_mais <- processa_perfil_mais()

source(here("bd/processor/ligacoes_economicas/processa_ligacoes_economicas.R"))
ligacoes_economicas <- processa_ligacoes_atividades_economicas()

source(here("bd/processor/atividades_economicas/processa_atividades_economicas.R"))
grupos_atividade_economica <- processa_atividade_economica()

source(here("bd/processor/empresas/processa_empresas.R"))
empresas <- processa_empresas()

source(here("bd/processor/empresas/processa_atividades_economicas_empresas.R"))
atividades_economicas_empresas <- processa_atividades_economicas_empresas()

message("Escrevendo dados em csv...")	
write_csv(parlamentares, paste0(output, "parlamentares.csv"))
write_csv(perguntas, paste0(output, "perguntas.csv"))
write_csv(proposicoes, paste0(output, "proposicoes.csv"))
write_csv(proposicoes_temas, paste0(output, "proposicoes_temas.csv"))
write_csv(respostas, paste0(output, "respostas.csv"))
write_csv(temas, paste0(output, "temas.csv"))
write_csv(votos, paste0(output, "votos.csv"))
write_csv(votacoes, paste0(output, "votacoes.csv"))
write_csv(orientacoes, paste0(output, "orientacoes.csv"))
write_csv(comissoes, paste0(output, "comissoes.csv"))
write_csv(composicao_comissoes, paste0(output, "composicao_comissoes.csv"))
write_csv(mandatos, paste0(output, "mandatos.csv"))
write_csv(liderancas, paste0(output, "liderancas.csv"))
write_csv(aderencia, paste0(output, "aderencia.csv"))
write_csv(partidos, paste0(output, "partidos.csv"))
write_csv(investimento_partidario_parlamentar, paste0(output, "investimento_partidario_parlamentar.csv"))
write_csv(investimento_partidario, paste0(output, "investimento_partidario.csv"))
write_csv(perfil_mais, paste0(output, "perfil_mais.csv"))
write_csv(grupos_atividade_economica, paste0(output, "atividades_economicas.csv"))
write_csv(ligacoes_economicas, paste0(output, "ligacoes_economicas.csv"))
write_csv(empresas, paste0(output, "empresas.csv"))
write_csv(atividades_economicas_empresas, paste0(output, "atividades_economicas_empresas.csv"))

message("Concluído")

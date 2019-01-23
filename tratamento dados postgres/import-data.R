if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

message("Leia o README deste diretório")
message("Use --help para mais informações\n")

option_list <- list(
  make_option(c("-f", "--folder"), 
              type="character", 
              default="vozativa", 
              help="pasta contendo os dados [default= %default]", 
              metavar="character"),
  make_option(c("-o", "--output"), 
              type="character", 
              default="import-csv-bd-vozativa.sql", 
              help="pasta contendo os dados [default= %default]", 
              metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)

opt <- parse_args(opt_parser)

folder <- opt$folder
output <- opt$output

temas <- paste0("\\", "copy temas FROM '", folder, "temas.csv' DELIMITER ',' CSV HEADER;")
candidatos <- paste0("\\", "copy candidatos FROM '", folder, "candidatos.csv' DELIMITER ',' CSV HEADER;")
perguntas <- paste0("\\", "copy perguntas FROM '", folder, "perguntas.csv' DELIMITER ',' CSV HEADER;")
proposicoes <- paste0("\\", "copy proposicoes FROM '", folder, "proposicoes.csv' DELIMITER ',' CSV HEADER;")
respostas <- paste0("\\", "copy respostas FROM '", folder, "respostas.csv' DELIMITER ',' CSV HEADER;")
votacoes <- paste0("\\", "copy votacoes FROM '", folder, "votacoes.csv' DELIMITER ',' CSV HEADER;")

import_tables <- data.frame(col = c(temas, candidatos, perguntas, proposicoes, respostas, votacoes))

write.table(x = import_tables, 
            file = output, 
            col.names = FALSE, 
            quote = FALSE, 
            row.names = FALSE)

message(paste0("Arquivo ", output ," criado com o código para importação das tabelas"))
message(paste0("Você pode importar os dados para o Banco Postgres usando: psql --username <seu-user> --dbname <seu-bd> < ", output))

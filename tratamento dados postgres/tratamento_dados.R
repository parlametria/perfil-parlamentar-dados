library(readr)
library(dplyr)

## 1. Criando o data frame de respostas completo ----

# Lê dados
respostas <- read_csv("./csv/respostas.csv")

# Remove variáveis irrelevantes
respostas <- respostas[-c(1:9)] 
respostas <- respostas[-c(48:55)] 

# Cria tabelas auxiliares, cada uma contendo o id da pergunta a resposta e o cpf do deputado
for(i in c(0:45)){
    nam <- paste("respostas_", i, sep = "")
    col <- paste("respostas/", i, sep = "")
    r <- respostas %>% select(c("cpf", col)) %>% mutate(pergunta_id = i)
    colnames(r) <- c("cpf", "resposta", "pergunta_id")
    assign(nam, r)
}

# Faz o rbind de todas as tabelas auxiliares
rm(col, nam, r, respostas, i)

datasets <- ls()

respostas <- respostas_0

datasets <- datasets[-1]

for (i in datasets){
  respostas <- rbind(respostas, get(i))
}

# Substitui NA por 0 (não respondeu)
respostas[is.na(respostas)] <- 0

## 2. Criando o data frame de candidatos completo ----

# Leitura dos dados necessaŕios 
candidatos <- read_csv("./csv/candidatos.csv")
respostas_raw <- read_csv("./csv/respostas.csv")

# Altera campo de date_modified para data
respostas_raw  <- respostas_raw %>% 
  mutate(date_modified = paste(substr(date_modified,0,10), substr(date_modified,12,19))) %>% 
  mutate(date_modified = ifelse(date_modified == "NA NA", NA, date_modified))

respostas_raw  <- respostas_raw %>% mutate(date_modified = as.POSIXct(date_modified))

# Cria counter para saber quantos cpfs duplicados existem

counter <- respostas_raw  %>% group_by(cpf) %>% count()  %>% filter(n > 1)
duplicated <- counter$cpf

duplicados <- respostas_raw %>% filter(cpf %in% duplicated)

# Ordena duplicados de maneira decrescente por cpf e data de modificação
duplicados <- duplicados[
  duplicados(duplicados, order(cpf, date_modified, decreasing = T )),
  ]

# Cria data frame com cpfs únicos
unicos <- duplicados[!duplicated(duplicados$cpf), ]

# Retira duplicados da data frame inicial
respostas_raw <- respostas_raw %>% anti_join(duplicados)

# Insere os cpfs únicos de volta
respostas_raw <- rbind(respostas_raw,unicos)

respostas_raw <- respostas_raw %>% select("cpf", "tem_foto", "reeleicao", "recebeu", "n_candidatura", "eleito", "respondeu")

# right join de candidatos com respostas para reter todas as informações necessaŕias
candidatos_full <- candidatos %>% right_join(respostas_raw)

candidatos_full <- candidatos_full %>% filter(!duplicated(cpf)) %>% select("estado", "uf", "idade_posse",
"nome_coligacao",
"nome_candidato",
"cpf",
"recebeu",
"num_partido",
"email",
"nome_social",
"nome_urna",
"reeleicao",
"ocupacao",
"nome_exibicao",
"raca",
"tipo_agremiacao",
"n_candidatura",
"composicao_coligacao",
"tem_foto",
"partido",
"sg_partido",
"grau_instrucao",
"genero",
"eleito",
"respondeu")

## 3. Formatando data frame de perguntas ----

# Leitura dos dados necessário
perguntas <- read_csv("./csv/perguntas.csv")

# Adiciona campo tema_id de acordo com o tema de cada pergunta
perguntas <- perguntas %>% mutate(tema_id = ifelse(tema =="Meio Ambiente",0, ifelse(tema == "Direitos Humanos", 1 , ifelse(tema == "Integridade e Transparência",2, ifelse(tema == "Nova Economia", 3 ,4)))))

perguntas <- perguntas %>% select("texto", "id", "tema_id")
 
## 4. Criando data frame de temas ----

temas <- as.data.frame(cbind(c("Meio Ambiente", "Direitos Humanos", "Integridade e Transparência", "Nova Economia", "Transversal"), c(0,1,2,3,4)))
colnames(temas) <- c("tema", "id")

## 5. Formatando data frame de proposições ----

# Leitura dos dados necessários
proposicoes <- read_csv("./csv/proposicoes.csv")

# Adiciona campo tema_id de acordo com o tema de cada pergunta
proposicoes <- proposicoes %>% mutate(tema_id = ifelse(tema =="Meio Ambiente",0, ifelse(tema == "Direitos Humanos", 1 , ifelse(tema == "Integridade e Transparência",2, ifelse(tema == "Nova Economia", 3 ,4)))))
proposicoes <- proposicoes[-6]
colnames(proposicoes) <- c("id", "projeto_lei", "id_votacao", "titulo", "descricao", "tema_id")

## 6. Formatando data frame de proposições ----

# Leitura dos dados necessários
votacoes <- read_csv("./csv/votacoes.csv")

# array auxiliar com ids das votações
id_votacoes <- c(
  "6259",
  "4968",
  "6517",
  "7252",
  "8175",
  "7317",
  "6531",
  "7927",
  "7291",
  "6608",
  "6095",
  "8309",
  "7566",
  "7546",
  "8334",
  "99999")

datasets <- c()

# Cria tabelas auxiliares, cada uma contendo o id da votacao a resposta e o id do usuário
ind <- 0
for(i in id_votacoes){
  nam <- paste("votacao_", i, sep = "")
  col <- paste("votacoes/", i, sep = "")
  r <- votacoes %>% select(c("cpf", col)) %>% mutate(proposicao_id = i)
  colnames(r) <- c("cpf", "resposta", "proposicao_id")
  assign(nam, r)
  datasets[ind] = nam
  ind <- ind + 1
}

# Faz o rbind de todas as tabelas auxiliares
votacoes <- votacao_4968

datasets <- datasets[-1]

for (i in datasets){
  votacoes <- rbind(votacoes, get(i))
}

## 7. Salva dados ----

write.csv(temas, "./final/temas.csv", row.names = FALSE)
write.csv(votacoes, "./final/votacoes.csv", row.names = FALSE)
write.csv(proposicoes, "./final/proposicoes.csv", row.names = FALSE)
write.csv(candidatos_full, "./final/candidatos.csv", row.names = FALSE)
write.csv(perguntas, "./final/perguntas.csv", row.names = FALSE)
write.csv(respostas, "./final/respostas.csv", row.names = FALSE)




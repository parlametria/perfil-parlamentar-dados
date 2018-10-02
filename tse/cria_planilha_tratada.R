#! /usr/bin/Rscript --vanilla --default-packages=utils
list.of.packages <- c("readr",  "stringi", "dplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)){
   res <- try(install.packages(new.packages))
}


library("readr")
library("stringi")
library("dplyr")

getwd()
setwd("/home/luiza/Documents/vozativa-monkey-ui/")
### 1. Importar Dados -----
AC <- read_delim("tse/dados candidatos/consulta_cand_2018_AC.csv", 
              ";", escape_double = FALSE,
              locale = locale(date_names = "pt", 
              encoding = "ISO-8859-1"), trim_ws = TRUE)

AL <- read_delim("tse/dados candidatos/consulta_cand_2018_AL.csv", 
                    ";", escape_double = FALSE,
                    locale = locale(date_names = "pt", 
                                    encoding = "ISO-8859-1"), trim_ws = TRUE)

AM <- read_delim("tse/dados candidatos/consulta_cand_2018_AM.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

AP <- read_delim("tse/dados candidatos/consulta_cand_2018_AP.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

BA <- read_delim("tse/dados candidatos/consulta_cand_2018_BA.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

BR <- read_delim("tse/dados candidatos/consulta_cand_2018_BR.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

CE <- read_delim("tse/dados candidatos/consulta_cand_2018_CE.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

DF <- read_delim("tse/dados candidatos/consulta_cand_2018_DF.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

ES <- read_delim("tse/dados candidatos/consulta_cand_2018_ES.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

GO <- read_delim("tse/dados candidatos/consulta_cand_2018_GO.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

MA <- read_delim("tse/dados candidatos/consulta_cand_2018_MA.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

MG <- read_delim("tse/dados candidatos/consulta_cand_2018_MG.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

MS <- read_delim("tse/dados candidatos/consulta_cand_2018_MS.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

MT <- read_delim("tse/dados candidatos/consulta_cand_2018_MT.csv", 
                    ";", escape_double = FALSE,
                    locale = locale(date_names = "pt", 
                                    encoding = "ISO-8859-1"), trim_ws = TRUE)

PA <- read_delim("tse/dados candidatos/consulta_cand_2018_PA.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

PB <- read_delim("tse/dados candidatos/consulta_cand_2018_PB.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

PE <- read_delim("tse/dados candidatos/consulta_cand_2018_PE.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

PI <- read_delim("tse/dados candidatos/consulta_cand_2018_PI.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

PR <- read_delim("tse/dados candidatos/consulta_cand_2018_PR.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

RJ <- read_delim("tse/dados candidatos/consulta_cand_2018_RJ.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

RN <- read_delim("tse/dados candidatos/consulta_cand_2018_RN.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

RO <- read_delim("tse/dados candidatos/consulta_cand_2018_RO.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

RR <- read_delim("tse/dados candidatos/consulta_cand_2018_RR.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

RS <- read_delim("tse/dados candidatos/consulta_cand_2018_RS.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

SC <- read_delim("tse/dados candidatos/consulta_cand_2018_SC.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

SE <- read_delim("tse/dados candidatos/consulta_cand_2018_SE.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

SP <- read_delim("tse/dados candidatos/consulta_cand_2018_SP.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

TO <- read_delim("tse/dados candidatos/consulta_cand_2018_TO.csv", 
                 ";", escape_double = FALSE,
                 locale = locale(date_names = "pt", 
                                 encoding = "ISO-8859-1"), trim_ws = TRUE)

### 2. Juntar todas as planilhas -----

datasets <- ls()

dados_completos <- AC

datasets <- datasets[-1]

for (i in datasets){
  dados_completos <- rbind(dados_completos, get(i))
  }


### 3. Filtrar dados relevantes -----

dados_completos <- dados_completos %>% filter(DS_CARGO == "DEPUTADO FEDERAL")
dados_completos <- dados_completos %>% select(SG_UF,NM_UE,NM_CANDIDATO,NM_URNA_CANDIDATO,
                                              NM_SOCIAL_CANDIDATO,NM_EMAIL,TP_AGREMIACAO,NR_PARTIDO,SG_PARTIDO,
                                              NM_PARTIDO, NM_COLIGACAO, DS_COMPOSICAO_COLIGACAO,NR_IDADE_DATA_POSSE,
                                              DS_GENERO,DS_GRAU_INSTRUCAO,DS_COR_RACA,DS_OCUPACAO,NR_CPF_CANDIDATO, ST_REELEICAO)




dados_completos <- dados_completos %>% mutate(NM_EXIBICAO = 
                                                ifelse(NM_SOCIAL_CANDIDATO != "#NULO#", NM_SOCIAL_CANDIDATO, NM_CANDIDATO))


### 4. Exportar dados

colnames(dados_completos) <- c("uf","estado","nome_candidato","nome_urna",
                               "nome_social","email","tipo_agremiacao","num_partido","sg_partido",
                               "partido", "nome_coligacao","composicao_coligacao","idade_posse",
                               "genero","grau_instrucao","raca","ocupacao","cpf","reeleicao","nome_exibicao")

dados_completos <- dados_completos %>% mutate(reeleicao = ifelse(reeleicao == "S",1,0))

dados_sem_rep <- dados_completos[!(duplicated(dados_completos$email) | duplicated(dados_completos$email, fromLast = TRUE)), ]
dados_mesmo_email <- dados_completos[(duplicated(dados_completos$email) | duplicated(dados_completos$email, fromLast=TRUE)),]


write.csv(dados_completos,"./tse/dados tratados/candidatos.csv",row.names = FALSE)
write.csv(dados_sem_rep,"./tse/dados tratados/emails_nao_repetidos.csv",row.names = FALSE)
write.csv(dados_mesmo_email,"./tse/dados tratados/emails_repetidos.csv",row.names = FALSE)

survey <- dados_sem_rep %>% select(email, nome_exibicao, nome_urna, genero,uf,estado,
                                   sg_partido,partido,cpf)

write.csv(survey,"./tse/dados tratados/survey.csv",row.names = FALSE)

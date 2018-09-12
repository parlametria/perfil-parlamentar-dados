import subprocess, sys, pprint,time
import keys4answers2json, questions2json, verifica_candidatos, escreve_json, request_file, monkey2json, keys
from pymongo import MongoClient, ReturnDocument

start_time = time.time()

# Dados TSE
request_file.main()
subprocess.call ("/usr/bin/Rscript --vanilla ./tse/cria_planilha_tratada.R", shell=True)
escreve_json.main()

# Survey Monkey
verifica_candidatos.main()
keys4answers2json.main()
questions2json.main()
monkey2json.main()

# Conectando ao banco de validação
client = MongoClient(keys.VALIDACAO_URI)
db = client.heroku_j4qrssbw
collection = db.respostas

jsonObj =  monkey2json.recupera_dados("./dados/respostas_novo.json")

i = 0
for candidato in jsonObj:
    collection.find_one_and_update(
   { "cpf" : candidato["cpf"] },
   { "$set": { "respostas" : candidato["respostas"], "respondeu": candidato["respondeu"],
    "recebeu": candidato["recebeu"], "date_created": candidato["date_created"], 
    "date_modified": candidato["date_modified"] }}, upsert=True)
    i += 1
    print(i)


collection = db.mudancas

jsonObj =  monkey2json.recupera_dados("./dados/mudancas.json")
i = 0
for alteracao in jsonObj:
    collection.find_one_and_update(
   { "data" : alteracao["data"], "alteracoes": alteracao["alteracoes"] },
   { "$set": { "alteracoes": alteracao["alteracoes"] }}, upsert=True)
    i += 1
    print(i)



print("--- %s seconds ---" % (time.time() - start_time))


import subprocess, sys, pprint,time
import keys4answers2json, questions2json, verifica_candidatos, escreve_json, request_file, monkey2json, keys
from pymongo import MongoClient, ReturnDocument

start_time = time.time()



# Conectando ao banco de validação
client = MongoClient(keys.VALIDACAO_URI)
db = client.heroku_j4qrssbw
collection = db.respostas



collection = db.candidatos
jsonObj =  monkey2json.recupera_dados("./tse/candidatos.json")
collection.drop()
collection.insert_many(jsonObj)

print("--- %s seconds ---" % (time.time() - start_time))


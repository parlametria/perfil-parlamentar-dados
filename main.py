import subprocess, sys, pprint,time
import keys4answers2json, questions2json, verifica_candidatos, escreve_json, request_file, monkey2json, keys
from pymongo import MongoClient

start_time = time.time()

def conecta_banco(URI):
    client = MongoClient(URI)
    db = client.heroku_j4qrssbw
    return db

def atualiza_respostas(db):
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
        print("Resposta de nº %s adicionada ou alterada" % i)

def atualiza_mudancas(db):
    collection = db.mudancas
    jsonObj =  monkey2json.recupera_dados("./dados/mudancas.json")

    i = 0
    for alteracao in jsonObj:
        collection.find_one_and_update(
    { "data" : alteracao["data"], "alteracoes": alteracao["alteracoes"] },
    { "$set": { "alteracoes": alteracao["alteracoes"] }}, upsert=True)
        i += 1
        print("Mudança de nº %s adicionada ou alterada" % i)

def atualiza_candidatos(db):
    collection = db.candidatos

    jsonObj =  monkey2json.recupera_dados("./tse/candidatos.json")
    collection.drop()
    collection.insert_many(jsonObj)
    print("Candidatos salvos")

def atualiza_validacao():
    db = conecta_banco(keys.VALIDACAO_URI)
    atualiza_respostas(db)
    atualiza_candidatos(db)
    atualiza_mudancas(db)
    
def atualiza_producao():
    db = conecta_banco(keys.PRODUCAO_URI)
    atualiza_respostas(db)
    atualiza_candidatos(db)
    atualiza_mudancas(db)
    
def main():
    # Dados TSE
    request_file.main()
    subprocess.call ("/usr/bin/Rscript --vanilla ./tse/cria_planilha_tratada.R", shell=True)
    escreve_json.main()

    # Survey Monkey
    verifica_candidatos.main()
    keys4answers2json.main()
    questions2json.main()
    monkey2json.main()

main()
atualiza_validacao()

print("--- %s seconds ---" % (time.time() - start_time))
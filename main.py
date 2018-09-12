import subprocess, sys, pprint, time, json
import keys4answers2json, questions2json, verifica_candidatos, escreve_json, request_file, monkey2json, keys
from pymongo import MongoClient

start_time = time.time()

def conecta_banco(URI, validacao):
    client = MongoClient(URI)
    if validacao:
        db = client.heroku_j4qrssbw
    else:
        db = client.heroku_15g9nm1x
    return db

def atualiza_respostas(db):
    collection = db.respostas
    jsonObj =  monkey2json.recupera_dados("./dados/respostas_novo.json")

    i = 0
    for candidato in jsonObj:
        collection.find_one_and_update(
    { "cpf" : candidato["cpf"] },
    { "$set": { "date_modified" : candidato["date_modified"], "date_created": candidato["date_created"],
        "email": candidato["email"], "respostas": candidato["respostas"], 
        "nome_urna": candidato["nome_urna"], "nome_exibicao": candidato["nome_exibicao"],
        "uf": candidato["uf"], "sg_partido": candidato["sg_partido"],
        "cpf": candidato["cpf"], "respondeu": candidato["respondeu"], 
        "tem_foto": candidato["tem_foto"], "recebeu": candidato["recebeu"] }}, upsert=True)
        i += 1
        print("Resposta de nº %s adicionada ou alterada" % i)

def atualiza_mudancas(db):
    collection = db.mudancas
    jsonObj =  monkey2json.recupera_dados("./dados/mudancas.json")

    i = 0
    for alteracao in jsonObj:
        collection.find_one_and_update(
    { "data" : alteracao["data"], "alteracoes": alteracao["alteracoes"] },
    { "$set": { "data" : alteracao["data"], "alteracoes": alteracao["alteracoes"]}}, upsert=True)
        i += 1
        print("Mudança de nº %s adicionada ou alterada" % i)

def atualiza_candidatos(db):
    collection = db.candidatos

    jsonObj =  monkey2json.recupera_dados("./tse/candidatos.json")
    collection.drop()
    collection.insert_many(jsonObj)
    print("Candidatos salvos")

def atualiza_validacao():
    db = conecta_banco(keys.VALIDACAO_URI,True)
    atualiza_respostas(db)
    atualiza_candidatos(db)
    atualiza_mudancas(db)
    
def atualiza_producao():
    db = conecta_banco(keys.PRODUCAO_URI, False)
    atualiza_respostas(db)
    atualiza_candidatos(db)
    atualiza_mudancas(db)

def pega_mudancas(db):
    collection = db.mudancas
    data_slim = "["

    for doc in collection.find({}):
        doc.pop("_id", None)
        data_slim += json.dumps(doc,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data_slim += ", "

    data_slim = data_slim[:-2]
    data_slim += "]"

    monkey2json.escreve_dados("./dados/mudancas.json", data_slim)


def pega_respostas(db):
    collection = db.respostas
    data_slim = "["

    for doc in collection.find({}):
        doc.pop("_id", None)
        data_slim += json.dumps(doc,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data_slim += ", "

    data_slim = data_slim[:-2]
    data_slim += "]"

    monkey2json.escreve_dados("./dados/respostas_slim.json", data_slim)

def main():
    # Dados TSE
    subprocess.call ("/usr/bin/Rscript --vanilla ./tse/cria_planilha_tratada.R", shell=True)
    escreve_json.main()

    # Survey Monkey
    verifica_candidatos.main()
    keys4answers2json.main()
    questions2json.main()
    monkey2json.main()

db = conecta_banco(keys.VALIDACAO_URI,True)
request_file.main()
pega_mudancas(db)
pega_respostas(db)
main()
atualiza_validacao()
# atualiza_producao()

print("--- %s seconds ---" % (time.time() - start_time))
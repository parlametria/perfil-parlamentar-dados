import keys
from pymongo import MongoClient

def nenhum_nulo():
    db = conecta_banco(keys.VALIDACAO_URI,True)
    query = db.respostas.find({"cpf": None})
    print(query.explain())

def conecta_banco(URI, validacao):
    client = MongoClient(URI)
    if validacao:
        db = client.heroku_j4qrssbw
    else:
        db = client.heroku_15g9nm1x
    return db


nenhum_nulo()
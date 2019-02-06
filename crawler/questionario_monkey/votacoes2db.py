import keys
from scripts.monkey2json import recupera_dados
from pymongo import MongoClient


def conecta_banco(URI, validacao):
    client = MongoClient(URI)
    if validacao:
        db = client.heroku_j4qrssbw
    else:
        db = client.heroku_15g9nm1x
    return db

def insere_votacoes(URI, val):
    db = conecta_banco(URI, val)

    jsonObj =  recupera_dados("./congresso/votacoes.json")
    db.votacoes.drop()
    db.votacoes.insert_many(jsonObj)
    print("Votações salvas")

insere_votacoes(keys.VALIDACAO_URI, True)
insere_votacoes(keys.PRODUCAO_URI, False)
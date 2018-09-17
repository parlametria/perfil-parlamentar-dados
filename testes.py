import keys
from pymongo import MongoClient

def nenhum_nulo(URI):
    num_nulos = 0
    db = conecta_banco(URI,True)

    query = db.respostas.find({"cpf": None})
    num_nulos += query.count()

    query = db.respostas.find({"email": None})
    num_nulos += query.count()

    query = db.respostas.find({"nome_urna": None})
    num_nulos += query.count()

    query = db.respostas.find({"uf": None})
    num_nulos += query.count()

    query = db.respostas.find({"respondeu": None})
    num_nulos += query.count()

    query = db.respostas.find({"tem_foto": None})
    num_nulos += query.count()

    query = db.respostas.find({"recebeu": None})
    num_nulos += query.count()

    query = db.respostas.find({"sg_partido": None})
    num_nulos += query.count()

    query = db.respostas.find({"nome_exibicao": None})
    num_nulos += query.count()

    query = db.respostas.find({"respostas": None})
    num_nulos += query.count()

    query = db.respostas.find({"date_modified": None})
    num_nulos += query.count()
    
    if num_nulos == 0:
        return True
    else:
        return False

def conecta_banco(URI, validacao):
    client = MongoClient(URI)
    if validacao:
        db = client.heroku_j4qrssbw
    else:
        db = client.heroku_15g9nm1x
    return db

def tamanho_banco(URI):
    db = conecta_banco(URI,True)
    if(db.respostas.find({}).count() <= db.candidatos.find({}).count()):
        return True
    else:
        return False

def nenhum_nulo_cand(URI):
    num_nulos = 0
    db = conecta_banco(URI,True)

    query = db.candidatos.find({"cpf": None})
    num_nulos += query.count()

    query = db.candidatos.find({"email": None})
    num_nulos += query.count()

    query = db.candidatos.find({"nome_urna": None})
    num_nulos += query.count()

    query = db.candidatos.find({"uf": None})
    num_nulos += query.count()

    query = db.candidatos.find({"estado": None})
    num_nulos += query.count()

    query = db.candidatos.find({"tem_foto": None})
    num_nulos += query.count()

    query = db.candidatos.find({"recebeu": None})
    num_nulos += query.count()

    query = db.candidatos.find({"sg_partido": None})
    num_nulos += query.count()

    query = db.candidatos.find({"nome_exibicao": None})
    num_nulos += query.count()

    query = db.candidatos.find({"partido": None})
    num_nulos += query.count()
    
    if num_nulos == 0:
        return True
    else:
        return False

def todos_presentes(URI):
    db = conecta_banco(URI,True)
    for cand in db.candidatos.find({}):
        query = db.respostas.find({"cpf": cand["cpf"]})
        if query.count() != 1:
            return False, cand["cpf"]
    return True, "Nenhum cpf duplicado ou nulo"

nenhum_nulo(keys.VALIDACAO_URI)
print(nenhum_nulo_cand(keys.VALIDACAO_URI))

print(todos_presentes(keys.VALIDACAO_URI))
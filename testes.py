import keys, monkey2json
from pymongo import MongoClient

def nenhum_nulo(db):
    num_nulos = 0

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

def tamanho_banco(db):

    if(db.respostas.find({}).count() <= db.candidatos.find({}).count()):
        return True
    else:
        return False

def nenhum_nulo_cand(db):
    num_nulos = 0

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

def todos_presentes(db):
    cpf_duplicado = []
    for cand in db.candidatos.find({}):
        query = db.respostas.find({"cpf": cand["cpf"]})
        if query.count() != 1:
            cpf_duplicado.append(cand["cpf"])
    
    if len(cpf_duplicado) > 0:
        return False, cpf_duplicado
    else:
        return True, "Nenhum cpf duplicado ou nulo"

def esta_atualizado(db):
    mudc = monkey2json.recupera_dados("./dados/mudancas.json")
    ind = 0
    for m in mudc:
        ind += 1
        if ind == len(mudc):
            mod = m["alteracoes"]
    
    total = 0
    print(mod)
    for m in mod:
        print(m)
        query = db.respostas.find({"cpf": m["cpf"]})
        if query.count() == 0:
            return False
        total += query.count()

    if total == len(mod):
        return True
    else:
        return False 

def main:
    db = conecta_banco(keys.VALIDACAO_URI, True)
    return(esta_atualizado(db) and todos_presentes(db) and nenhum_nulo_cand(db) and tamanho_banco(db) and nenhum_nulo(db))
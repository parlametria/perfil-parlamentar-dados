import keys, scripts.monkey2json
import smtplib, email
from pymongo import MongoClient
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def nenhum_nulo(db, log):
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
        return True, log
    else:
        log += "\n ERRO: algum campo nulo foi encontrado em respostas"
        return False, log

def conecta_banco(URI, validacao):
    client = MongoClient(URI)
    if validacao:
        db = client.heroku_j4qrssbw
    else:
        db = client.heroku_15g9nm1x
    return db

def tamanho_banco(db, log):

    if(db.respostas.find({}).count() <= db.candidatos.find({}).count()):
        return True, log
    else:
        log += "\n ERRO: número incongruente de respostas"
        return False, log

def nenhum_nulo_cand(db, log):
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
        return True, log
    else:
        log += "\n ERRO: algum campo nulo encontrado em candidatos"
        return False, log 

def todos_presentes(db, log):
    cpf_duplicado = []
    for cand in db.candidatos.find({}):
        query = db.respostas.find({"cpf": cand["cpf"]})
        if query.count() != 1:
            cpf_duplicado.append(cand["cpf"])
    
    if len(cpf_duplicado) > 0:
        log += "\n ERRO: CPF duplicado ou inexistente: %s" % cpf_duplicado
        return False, log
    else:
        return True, log

def esta_atualizado(db, log):
    mudc = scripts.monkey2json.recupera_dados("./dados/mudancas.json")
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
        return True, log
    else:
        log += "\n ERRO: Banco não está atualizado"
        return False, log

def main(URI, cond):
    db = conecta_banco(URI, cond)
    if(cond):
        log = "[Log de Erros - VALIDAÇÃO]"
    else:
        log = "[Log de Erros - PRODUÇÃO]"

    erro, log = esta_atualizado(db, log)
    if (not erro):
        enviaEmail(log)
        return False

    erro, log = todos_presentes(db, log)
    if (not erro):
        enviaEmail(log)
        return False

    erro, log = nenhum_nulo_cand(db, log)
    if (not erro):
        enviaEmail(log)
        return False
    
    
    erro, log = nenhum_nulo(db, log)
    if (not erro):
        enviaEmail(log)
        return False
    

    erro, log = tamanho_banco(db, log)
    if (not erro):
        enviaEmail(log)
        return False

    scripts.monkey2json.escreve_dados("erros.log", log)

    return True

def enviaEmail(log):
    toaddr = "luiza.silveira@ccc.ufcg.edu.br"
    msg = MIMEMultipart()
    msg['From'] = keys.email
    msg['To'] = toaddr
    msg['Subject'] = "[ERRO NO BD: VozAtiva]"
    
    msg.attach(MIMEText(log, 'plain'))
    
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(keys.email, keys.senha_email) 
    text = msg.as_string()    
    server.sendmail(keys.email, toaddr, text)
    server.quit()
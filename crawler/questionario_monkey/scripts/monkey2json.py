import keys
import requests
import json
import datetime
from datetime import timedelta,datetime, date
import os, csv

NAO_RESPONDEU = 0

# Verifica se um candidato possui foto na base de dados
def tem_foto(candidato_json):
    lista = os.listdir("./fotos_tratadas/")
    for i in lista:
        if("tem_foto" in candidato_json.keys()):
            if(candidato_json["cpf"] == i[4:15]):
                candidato_json["tem_foto"] = 1
            else:
                candidato_json["tem_foto"] = candidato_json["tem_foto"]

        elif (candidato_json["cpf"] == i[4:15]):
            candidato_json["tem_foto"] = 1 
        else:
            candidato_json["tem_foto"] = 0    
    
    return candidato_json
    
# Recupera o json contendo todos os dados de todos candidatos fornecidos pelo tse e formata ele
def get_todos_candidatos():
    with open('./tse/candidatos.json') as f:
        candidatos = json.load(f)
    
    candidatos[:] = [d for d in candidatos if d.get('cpf') != "cpf"]

    for elem in candidatos:
        elem.pop('ocupacao', None)
        elem.pop('estado', None)
        elem.pop('nome_social', None)
        elem.pop('nome_candidato', None)
        elem.pop('tipo_agremiacao', None)
        elem.pop('num_partido', None)
        elem.pop('partido', None)
        elem.pop('raca', None)
        elem.pop('nome_coligacao', None)
        elem.pop('composicao_coligacao', None)
        elem.pop('idade_posse', None)
        elem.pop('genero', None)
        elem.pop('grau_instrucao', None)
        elem['respostas'] = {}
        elem['date_modified'] = ""
        elem['date_created'] = ""
        elem['respondeu'] = False

        for i in range(46):
            elem['respostas'][str(i)] = 0

        if len(elem["cpf"]) < 11:
            elem["cpf"] = (11 - len(elem["cpf"]))*"0" + elem["cpf"]
        
        elem = tem_foto(elem)

    return candidatos

def get_todos_candidatos_b():
    with open('./tse/candidatos.json') as f:
        candidatos = json.load(f)
    
    candidatos[:] = [d for d in candidatos if d.get('cpf') != "cpf"]

    for elem in candidatos:
        if len(elem["cpf"]) < 11:
            elem["cpf"] = (11 - len(elem["cpf"]))*"0" + elem["cpf"]
        
        elem = tem_foto(elem)

    return candidatos
 

 # Altera candidato para se adequar ao padrão            
def change_candidato(json_candidato):
    json_candidato.pop("custom_variables", None)
    json_candidato.pop("edit_url", None)
    json_candidato.pop("analyze_url", None)
    json_candidato.pop("collection_mode", None)
    json_candidato.pop("survey_id",None)
    json_candidato.pop("logic_path", None)
    json_candidato.pop("page_path", None)
    json_candidato.pop("ip_address", None)
    json_candidato.pop("href", None)

    json_candidato["nome_urna"] = json_candidato.pop("last_name", None)
    json_candidato["nome_exibicao"] = json_candidato.pop("first_name", None)
    json_candidato["genero"] = json_candidato.pop("custom_value", None)
    json_candidato["uf"] = json_candidato.pop("custom_value2", None)
    json_candidato["estado"] = json_candidato.pop("custom_value3", None)
    json_candidato["sg_partido"] = json_candidato.pop("custom_value4", None)
    json_candidato["partido"] = json_candidato.pop("custom_value5", None)
    json_candidato["cpf"] = json_candidato.pop("custom_value6", None)

    # Lista de ids perguntas iniciais do questionário
    must = {"129411238", "129521027", "129520614" }
    # Verifica se o candidato respondeu as perguntas iniciais do questionário e se respondeu alguma outra além dessas
    # Se sim marca respondeu como True
    if len(json_candidato["respostas"]) > len(must) and all(key in json_candidato["respostas"] for key in must):
        json_candidato["respondeu"] = True
    else: 
        json_candidato["respondeu"] = False

    if len(json_candidato["cpf"]) < 11:
        json_candidato["cpf"] = (11 - len(json_candidato["cpf"])) * "0" + json_candidato["cpf"]
    
    # Erro de digitação do candidato no TSE quebrou esse contato no Survey Monkey
    if json_candidato["nome_exibicao"] == "CARLOS AUGUSTO PEREIRA DA SILVA":
        json_candidato["nome_urna"] = "DR. CARLOS AUGUSTO"
        json_candidato["nome_exibicao"] = "CARLOS AUGUSTO PEREIRA DA SILVA"
        json_candidato["genero"] = "MASCULINO"
        json_candidato["uf"] = "SP"
        json_candidato["estado"] = "SÃO PAULO"
        json_candidato["sg_partido"] = "PV"
        json_candidato["partido"] = "PARTIDO VERDE"
        json_candidato["cpf"] = "76760456815"

    json_candidato = tem_foto(json_candidato)

    return json_candidato

# Mais formatação para deixar o candidato padronizado 
def candidato_slim(candidato):
    candidato.pop("genero", None)
    candidato.pop("estado", None)
    candidato.pop("partido", None)
    candidato.pop("recipient_id", None)
    candidato.pop("total_time", None)
    candidato.pop("response_status", None)
    candidato.pop("collector_id", None)
    candidato.pop("id", None)

    return candidato
    
# Função principal de requisição das respostas dos candidatos

def request_page(page_url, data_slim):
    s = requests.Session()
    s.headers.update({
    "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
    "Content-Type": "application/json"
    })
    payload = {'per_page': 100}
    request = s.get(page_url, params=payload)

    temp = json.loads(request.text)        

    # Json contendo o id das respostas de cada pergunta 
    with open("./dados/keys_answers.json", 'r') as f:
       keys4answers = json.load(f)

    # Json contendo o id de cada pergunta
    with open("./dados/id_perguntas.json", 'r') as f:
       id_perguntas = json.load(f)

    # Itera sobre o json fornecido pelo survey monkey e cria o json da base de dados
    for valor_data in temp["data"]:
        json_candidato_slim = {}
        json_candidato = {}
        json_perguntas = {}
        for (key, value) in valor_data.items():        
            if key == "pages":
                # Dentro da chave pages itera sobre seus subelementos para achar as respostas das perguntas 
                for elem in valor_data[key]:
                    for subelem in elem['questions']:
                        pergunta = subelem['id']
                        # Se houver resposta se cruza os dados com keys4answers, pega seu id e transforma numa resposta válida
                        if 'choice_id' in subelem['answers'][0].keys():
                            resposta = subelem['answers'][0]['choice_id']
                            if pergunta == "129411238": 
                                json_perguntas[pergunta] = keys4answers[pergunta][resposta]
                            else:    
                                json_perguntas[id_perguntas[pergunta]] = keys4answers[pergunta][resposta]
                        # Caso a resposta seja um campo de texto ele é mantido como resposta ao invés de ocorrer cruzamento de dados
                        elif 'text' in subelem['answers'][0].keys():
                            resposta = subelem['answers'][0]['text']
                            json_perguntas[pergunta] = resposta
                        else:
                            json_perguntas[pergunta] = NAO_RESPONDEU

            # Pega os dados de metadata, que são os dados pessoais do candidatos                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
            elif key == "metadata":
                for (chave,valor) in valor_data[key]["contact"].items():
                    json_candidato[chave] = valor['value']
            # Salva também o restante dos dados             
            else:
                json_candidato[key] = value

        json_candidato["respostas"] = json_perguntas  

        # Padronizando o candidato
        json_candidato = change_candidato(json_candidato)
        json_candidato_slim =  candidato_slim(json_candidato)

        # Salva json de candidato com string
        data_slim += json.dumps(json_candidato_slim,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data_slim += ", "
    
    # Se existir outra página de respostas chama novamente a função
    if 'next' in temp["links"].keys():
        nextPage = temp["links"]["next"]
        return(request_page(nextPage, data_slim))

    # Se não, retorna o json criado    
    else:
        data_slim = data_slim[:-2]
        data_slim += "]"
        return data_slim

# Compara dados do tse com dados do survey monkey
def compara_candidatos(candidatos_tse, data_slim_clone, data_slim):
    lista_candidatos_tse = []
    for candidato in candidatos_tse:
        lista_candidatos_tse.append(candidato["cpf"])

    lista_resultados = []
    for resultado in data_slim_clone:
        if resultado["cpf"] != None:
            lista_resultados.append(resultado["cpf"])

    lista_final =  [x for x in lista_candidatos_tse if x not in lista_resultados]

    print(len(lista_candidatos_tse))
    print(len(lista_resultados))
    print(len(lista_final))
    
    data_slim = "["
    for candidato in candidatos_tse:
        if candidato["cpf"] in lista_final:
            data_slim += json.dumps(candidato, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
            data_slim += ", "

    for candidato in data_slim_clone:
        for c in candidatos_tse:
            if candidato["cpf"] == c["cpf"]:
                candidato["reeleicao"] = c["reeleicao"]
                data_slim += json.dumps(candidato, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
                data_slim += ", "


    data_slim = data_slim[:-2]
    data_slim += "]"
    return data_slim

# Cria data em formato Date ao passar um json que contém um campo de string
def cria_data(c):
    strs = c["date_modified"]
    strs = strs[::-1].replace(':','',1)[::-1]
    return datetime.strptime(strs[:-5], "%Y-%m-%dT%H:%M:%S")

# Procura alterações no banco de dados
def procura_alteracoes(data_old, data_slim):
    old_unique = { each['cpf'] : each for each in data_old }.values()

    alteracoes = []
    for cand in data_slim:
        for c in old_unique:
            if cand["cpf"] == c["cpf"]:
                if c["date_modified"] == "":
                    date_old = datetime.strptime("0001-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S")
                else:
                    date_old = cria_data(c)
                if cand["date_modified"] == "":
                    date_new = datetime.strptime("0001-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S")
                else:
                    date_new  = cria_data(cand) 
                
                if date_new > date_old:
                    alteracoes.append(cand)
    return alteracoes

def escreve_dados(caminho,dados):
    with open(caminho, 'w') as file:
        file.write(dados)    

def recupera_dados(caminho):
    with open(caminho) as file:
        dados = json.load(file)
    return dados

# Verifica se existem alterações e as salva, também salva log de alterações
def salva_alteracoes(alteracoes, dados_alterados, mudancas):
    print("Quantidade de candidatos com alteração: %s" % len(alteracoes))
    if len(alteracoes) > 0:
        print("Existem alterações")
        dados_alterados = dados_alterados[:-1]
        dados_alterados += ", "
        for candidato in alteracoes:
            print(candidato)
            dados_alterados += json.dumps(candidato, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
            dados_alterados += ", "
        dados_alterados = dados_alterados[:-2]
        dados_alterados += "]"

        today = datetime.now()
    
        log = {"data": today.isoformat(), "alteracoes": alteracoes}
        
        # Salvando log das alterações
        mudancas = mudancas[:-1]
        mudancas += ", "
        mudancas += json.dumps(log, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        mudancas += "]"
        escreve_dados("./dados/mudancas.json", mudancas)

        return dados_alterados
    else: 
        print("Não Existem alterações")
        return dados_alterados

def insere_flag_recebeu(data_final, candidatos):
    dados = "["
    for elem in data_final:
        for cand in candidatos:
            if "cpf" in cand.keys():
                if elem["cpf"] == cand["cpf"]:
                    elem["recebeu"] = cand["recebeu"]

    for elem in data_final:
        dados += json.dumps(elem, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        dados += ", "

    dados = dados[:-2]
    dados += "]"
    return dados

def insere_qnt_eleicoes(candidatos):

    csvfile = open('./congresso/dados congresso/candidatos2018_count_candidaturas.csv', "r", encoding="latin-1")
   
    names = ("cpf",	"display_name",	"name",	"count(e.year)",	"group_concat(e.year)")

    reader = csv.DictReader( csvfile, names)

    dados = "["
    for elem in reader:
        if len(elem["cpf"]) < 11:
            elem["cpf"] = (11 - len(elem["cpf"]))*"0" + elem["cpf"]
        for cand in candidatos:
            if "cpf" in cand.keys():
                if elem["cpf"] == cand["cpf"]:
                    cand["n_candidatura"] = elem["count(e.year)"]
                    cand["candidaturas"] = elem["group_concat(e.year)"]

    for elem in candidatos:
        if not ("n_candidatura" in elem.keys()):
            elem["n_candidatura"] = 0
            elem["candidaturas"] = 0

        dados += json.dumps(elem, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        dados += ", "

    dados = dados[:-2]
    dados += "]"
    return dados

def insere_flag_eleito(dados_originais):

    dados_eleitos = recupera_dados("./tse/eleitos1.json")
    dados_string = "["
    for elem in dados_originais:
        for e in dados_eleitos:
            if (elem["nome_urna"].upper().rstrip() == e["nome_urna"].upper().rstrip()) and (elem["uf"].upper() == e["uf"].upper()):
                elem["eleito"] = e["eleito"]

        if elem["nome_urna"] == "CHICO D ANGELO":
                elem["eleito"] = True
        
        if "eleito" not in elem.keys():
            elem["eleito"] = False
        
        dados_string += json.dumps(elem, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        dados_string += ", "
    
    dados_string = dados_string[:-2]
    dados_string += "]"

    return dados_string

def main(): 
    url = "https://api.surveymonkey.com/v3/surveys/%s/responses/bulk" % (keys.survey_id)
    
    data_slim = "[ "
    print("Iniciando request")
    # Realiza request e salva todas as respostas do Survey Monkey
    data_slim = request_page(url, data_slim)
    candidatos = get_todos_candidatos()
    escreve_dados("./dados/respostas_novo.json", data_slim)

    # Compara respostas do Survey Monkey com Json de candidatos do TSE e salva dados completos    
    print("Comparando csv de candidatos com os resultados do SM") 
    data_slim_clone = recupera_dados("./dados/respostas_novo.json")
    data_slim = compara_candidatos(candidatos,data_slim_clone, data_slim)
    escreve_dados("./dados/respostas_novo.json", data_slim)

    # Verifica se o candidato recebeu email e insere a flag
    data_final = recupera_dados("./dados/respostas_novo.json")
    candidatos = recupera_dados("./dados/candidatos_sent.json")
    print("Inserindo flag recebeu")
    dados = insere_flag_recebeu(data_final, candidatos)
    escreve_dados('./dados/respostas_novo.json', dados)

    # Insere quantidade de eleições do candidato
    print("Inserindo flag qnt eleições")
    data_slim = recupera_dados("./dados/respostas_novo.json")
    dados_slim = insere_qnt_eleicoes(data_slim)
    escreve_dados('./dados/respostas_novo.json', dados_slim)

    # Adiciona flag eleito
    print("Inserindo flag eleito")
    data_slim = recupera_dados("./dados/respostas_novo.json")
    dados_slim = insere_flag_eleito(data_slim)
    escreve_dados('./dados/respostas_novo.json', dados_slim)
    
    # Procura alterações no banco de dados
    print("Procurando alterações em respostas")
    data_old = recupera_dados("./dados/respostas_slim.json")
    data_slim = recupera_dados("./dados/respostas_novo.json")
    
    dados_alterados = json.dumps(data_old, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

    alteracoes = procura_alteracoes(data_old,data_slim)
    mudcs = recupera_dados("./dados/mudancas.json")
    mudcs = json.dumps(mudcs, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

    dados_alterados = salva_alteracoes(alteracoes, dados_alterados, mudcs)

    print("Salvando os dados")
    escreve_dados('./dados/respostas_slim.json', dados_alterados)

    # Salva candidatos com flag recebeu e tem_foto
    candidatos = get_todos_candidatos_b()
    cand_sent = recupera_dados("./dados/candidatos_sent.json")
    candidatos = insere_flag_recebeu(candidatos,cand_sent)
    escreve_dados("./tse/candidatos.json", candidatos)
    candidatos = recupera_dados("./tse/candidatos.json")
    candidatos = insere_qnt_eleicoes(candidatos)    

    escreve_dados("./tse/candidatos.json", candidatos)

        
    print("finalizado")
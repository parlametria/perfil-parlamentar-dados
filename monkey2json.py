# encoding: iso-8859-1
import keys
import requests
import json
import datetime
from datetime import timedelta,datetime
import os

NAO_RESPONDEU = 0

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
        elem['respondeu'] = False

        for i in range(46):
            elem['respostas'][str(i)] = 0

        if len(elem["cpf"]) < 11:
            elem["cpf"] = (11 - len(elem["cpf"]))*"0" + elem["cpf"]
        
        elem = tem_foto(elem)

    return candidatos
            
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

    must = {"129411238", "129521027", "129520614" }
    if len(json_candidato["respostas"]) > len(must) and all(key in json_candidato["respostas"] for key in must):
        json_candidato["respondeu"] = True
    else: 
        json_candidato["respondeu"] = False

    if len(json_candidato["cpf"]) < 11:
        json_candidato["cpf"] = (11 - len(json_candidato["cpf"])) * "0" + json_candidato["cpf"]

    json_candidato = tem_foto(json_candidato)

    return json_candidato

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
    

def request_page(page_url, data, data_slim):
    payload = {'per_page': 100}
    request = s.get(page_url, params=payload)

    temp = json.loads(request.text)        
     
    with open("keys_answers.json", 'r') as f:
       keys4answers = json.load(f)
    
    with open("id_perguntas.json", 'r') as f:
       id_perguntas = json.load(f)
    
    for valor_data in temp["data"]:
        json_candidato_slim = {}
        json_candidato = {}
        json_perguntas = {}
        for (key, value) in valor_data.items():        
            if key == "pages":
                for elem in valor_data[key]:
                    for subelem in elem['questions']:
                        pergunta = subelem['id']
                        if 'choice_id' in subelem['answers'][0].keys():
                            resposta = subelem['answers'][0]['choice_id']
                            if pergunta == "129411238":
                                json_perguntas[pergunta] = keys4answers[pergunta][resposta]
                            else:    
                                json_perguntas[id_perguntas[pergunta]] = keys4answers[pergunta][resposta]
                        elif 'text' in subelem['answers'][0].keys():
                            resposta = subelem['answers'][0]['text']
                            json_perguntas[pergunta] = resposta
                        else:
                            json_perguntas[pergunta] = NAO_RESPONDEU
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
            elif key == "metadata":
                for (chave,valor) in valor_data[key]["contact"].items():
                    json_candidato[chave] = valor['value']     
            else:
                json_candidato[key] = value

        json_candidato["respostas"] = json_perguntas  

        json_candidato = change_candidato(json_candidato)
        json_candidato_slim =  candidato_slim(json_candidato)

        data_slim += json.dumps(json_candidato_slim,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data_slim += ", "

        data += json.dumps(json_candidato,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data += ", "

    

    if 'next' in temp["links"].keys():
        nextPage = temp["links"]["next"]
        return(request_page(nextPage, data, data_slim))
    else:
        data = data[:-2]
        data += "]"
        data_slim = data_slim[:-2]
        data_slim += "]"
        return data, data_slim

def compara_candidatos(candidatos, data_slim_clone, data_slim):
    lista_candidatos = []
    for candidato in candidatos:
        lista_candidatos.append(candidato["cpf"])

    lista_resultados = []
    for resultado in data_slim_clone:
        if resultado["cpf"] != None:
            lista_resultados.append(resultado["cpf"])

    lista_final =  [x for x in lista_candidatos if x not in lista_resultados]

    print(len(lista_candidatos))
    print(len(lista_resultados))
    print(len(lista_final))
    
    data_slim = data_slim[:-1]
    data_slim += ", "
    for candidato in candidatos:
        if candidato["cpf"] in lista_final:
            data_slim += json.dumps(candidato, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
            data_slim += ", "

    data_slim = data_slim[:-2]
    data_slim += "]"
    return data_slim

def procura_alteracoes(data_old, data_slim):
    lista_cpf = []
    lista_tempo_final = []
    old_unique = { each['cpf'] : each for each in data_old }.values()

    alteracoes = []
    for cand in data_slim:
        for c in old_unique:
            if cand["cpf"] == c["cpf"]:
                if c["date_modified"] == "":
                    date_old = datetime.strptime("0001-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S")
                else:
                    strs = c["date_modified"]
                    strs = strs[::-1].replace(':','',1)[::-1]
                    date_old = datetime.strptime(strs[:-5], "%Y-%m-%dT%H:%M:%S")
                if cand["date_modified"] == "":
                    date_new = datetime.strptime("0001-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S")
                else:
                    strs = cand["date_modified"]
                    strs = strs[::-1].replace(':','',1)[::-1]
                    date_new  = datetime.strptime(strs[:-5], "%Y-%m-%dT%H:%M:%S") 
                
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

s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

url = "https://api.surveymonkey.com/v3/surveys/%s/responses/bulk" % (keys.survey_id)
data = "[ "
data_slim = "[ "

print("iniciando request")

data, data_slim = request_page(url,data, data_slim)

candidatos = get_todos_candidatos()

escreve_dados("respostas_novo.json", data_slim)

print("Comparando csv de candidatos com os resultados do SM") 

data_slim_clone = recupera_dados("respostas_novo.json")

data_slim = compara_candidatos(candidatos,data_slim_clone, data_slim)

escreve_dados("respostas_novo.json", data_slim)

print("Procurando alterações em respostas")

data_old = recupera_dados("respostas_slim.json")
data_slim = recupera_dados("respostas_novo.json")

dados_alterados = json.dumps(data_old, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

alteracoes = procura_alteracoes(data_old,data_slim)

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
    print("Salvando os dados")
    with open('respostas_slim.json', 'w') as file:
        file.write(dados_alterados)
else: 
    print("Não Existem alterações")

data_final = recupera_dados("respostas_slim.json")
candidatos = recupera_dados("candidatos_sent.json")

dados = "["
for elem in data_final:
    for cand in candidatos:
        if elem["cpf"] == cand["cpf"]:
            elem["recebeu"] = cand["recebeu"]

for elem in data_final:
    dados += json.dumps(elem, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
    dados += ", "

dados[:-2]
dados += "]"
with open('respostas_slim.json', 'w') as file:
        file.write(dados)


print("finalizado")



import requests
import json
import keys

# Altera candidato para que uma nova flag "recebeu" seja um de seus atributos e altera nome de campos
def change_candidato(cand):
  # Recebeu indica se um candidato recebeu o email para responder o formulário
  cand["recebeu"] = cand.pop("mail_status", None)
  if cand["recebeu"] == "sent":
    cand["recebeu"] = True
  else:
    cand["recebeu"] = False
  
  cand["nome_urna"] = cand.pop("last_name", None)
  cand["nome_exibicao"] = cand.pop("first_name", None)
  cand.pop("survey_response_status", None)
  cand.pop("id", None)
  cand.pop("href", None)

  return cand

# Função para recuperar todos os candidatos a quem foi enviado um email 
def request_page(page_url, data):
    s = requests.session()
    s.headers.update({
      "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
      "Content-Type": "application/json"
    })

    payload = {'per_page': 1000, 'include': "survey_response_status,mail_status,custom_fields"}
    request = s.get(page_url, params=payload)

    temp = json.loads(request.text)        
    for dados in temp["data"]:
      candidato = {}
      for (key, value) in dados.items():        
        if key == "custom_fields":
          for (chave, valor) in dados[key].items():
            if chave == "6":
              candidato["cpf"] = valor
              if len(candidato["cpf"]) < 11:
                candidato["cpf"] = (11 - len(candidato["cpf"]))*"0" + candidato["cpf"]
        
        else:
          candidato[key] = value
      
      candidato = change_candidato(candidato)
      
      data += json.dumps(candidato,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
      data += ", "


    if 'next' in temp["links"].keys():
        nextPage = temp["links"]["next"]
        return(request_page(nextPage, data))
    else:
        data = data[:-2]
        data += "]"
        return data

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

        if len(elem["cpf"]) < 11:
            elem["cpf"] = (11 - len(elem["cpf"]))*"0" + elem["cpf"]
        
    return candidatos

# Compara os dados do survey monkey com os do json dos dados do tse para verificar quais candidatos receberam email ou não 
def compara_candidatos(todos, sent, data):

    for elem in todos:
      for can in sent:
        if "cpf" in can.keys():
          if elem["cpf"] == can["cpf"]:
            elem["recebeu"] = can["recebeu"]
            data += json.dumps(elem,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
            data += ", "


    for elem in todos:
      if "recebeu" not in elem.keys():
        elem["recebeu"] = False
        data += json.dumps(elem,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data += ", "

    return data

def main():
  url = "https://api.surveymonkey.com/v3/collectors/%s/recipients" % (keys.collector_id)

  data = "["
  print("Fazendo request dos dados dos candidatos")
  data = request_page(url, data)

  with open('./dados/candidatos_sent.json', 'w') as file:
      file.write(data)

  with open("./dados/candidatos_sent.json") as file:
      enviados = json.load(file)

  print("Comparando com os dados do TSE")
  todos_candidatos = get_todos_candidatos()

  dados = "["
  dados += compara_candidatos(todos_candidatos,enviados, dados)
  dados = dados[:-2]
  dados += "]"
  dados = dados[1:]

  print("Salva dados com a nova flag")
  with open('./dados/candidatos_sent.json', 'w') as file:
      file.write(dados)

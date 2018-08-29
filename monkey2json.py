# encoding: iso-8859-1
import keys
import requests
import json

NAO_RESPONDEU = '0'

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

    return json_candidato

def candidato_slim(candidato):
    candidato.pop("genero", None)
    candidato.pop("estado", None)
    candidato.pop("partido", None)
    candidato.pop("recipient_id", None)
    candidato.pop("date_modified", None)
    candidato.pop("date_modified", None)
    candidato.pop("date_created", None)
    candidato.pop("total_time", None)
    candidato.pop("response_status", None)
    candidato.pop("collector_id", None)
    candidato.pop("id", None)
    candidato.pop("email", None)

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

with open('respostas.json', 'w') as file:
    file.write(data)

with open('respostas_slim.json', 'w') as file:
    file.write(data_slim)

print("finalizado")



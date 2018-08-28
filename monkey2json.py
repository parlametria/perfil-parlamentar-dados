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

    json_candidato["nome_urna"] = json_candidato.pop("last_name", None)
    json_candidato["nome_exibicao"] = json_candidato.pop("first_name", None)
    json_candidato["genero"] = json_candidato.pop("custom_value", None)
    json_candidato["uf"] = json_candidato.pop("custom_value2", None)
    json_candidato["estado"] = json_candidato.pop("custom_value3", None)
    json_candidato["sg_partido"] = json_candidato.pop("custom_value4", None)
    json_candidato["partido"] = json_candidato.pop("custom_value5", None)
    json_candidato["cpf"] = json_candidato.pop("custom_value6", None)

    return json_candidato

def request_page(page_url, data):
    payload = {'per_page': 100}
    request = s.get(page_url, params=payload)

    temp = json.loads(request.text)        
    
    with open("keys_answers.json", 'r') as f:
       keys4answers = json.load(f)
    
    with open("id_perguntas.json", 'r') as f:
       id_perguntas = json.load(f)
    
    for valor_data in temp["data"]:
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

        data += json.dumps(json_candidato,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data += ", "

    

    if 'next' in temp["links"].keys():
        nextPage = temp["links"]["next"]
        return(request_page(nextPage, data))
    else:
        data = data[:-2]
        data += "]"
        return data


s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

url = "https://api.surveymonkey.com/v3/surveys/%s/responses/bulk" % (keys.survey_id)
data = "[ "

print("iniciando request")
            
data = request_page(url,data)

with open('respostas.json', 'w') as file:
    file.write(data)

print("finalizado")



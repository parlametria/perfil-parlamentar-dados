# encoding: iso-8859-1
import keys
import requests
import json

NAO_RESPONDEU = '-2'

def changeCandidato(jsonCandidato):
    jsonCandidato.pop("custom_variables", None)
    jsonCandidato.pop("edit_url", None)
    jsonCandidato.pop("analyze_url", None)
    jsonCandidato.pop("collection_mode", None)
    jsonCandidato.pop("survey_id",None)
    jsonCandidato.pop("logic_path", None)
    jsonCandidato.pop("page_path", None)
    jsonCandidato.pop("ip_address", None)

    jsonCandidato["nome_urna"] = jsonCandidato.pop("last_name", None)
    jsonCandidato["nome_exibicao"] = jsonCandidato.pop("first_name", None)
    jsonCandidato["genero"] = jsonCandidato.pop("custom_value", None)
    jsonCandidato["uf"] = jsonCandidato.pop("custom_value2", None)
    jsonCandidato["estado"] = jsonCandidato.pop("custom_value3", None)
    jsonCandidato["sg_partido"] = jsonCandidato.pop("custom_value4", None)
    jsonCandidato["partido"] = jsonCandidato.pop("custom_value5", None)
    jsonCandidato["cpf"] = jsonCandidato.pop("custom_value6", None)

    return jsonCandidato

def requestPage(pageUrl, data):
    payload = {'per_page': 100}
    request = s.get(pageUrl, params=payload)

    temp = json.loads(request.text)        
    
   
    for valorData in temp["data"]:
        jsonCandidato = {}
        idPerguntas = []
        idRespostas = []
        for (key, value) in valorData.items():
            if key == "pages":
                for elem in valorData[key]:
                    for subelem in elem['questions']:
                        idPerguntas.append(subelem['id'])
                        if 'choice_id' in subelem['answers'][0].keys():
                            idRespostas.append(subelem['answers'][0]['choice_id'])
                        elif 'text' in subelem['answers'][0].keys():
                            idRespostas.append(subelem['answers'][0]['text'])
                        else:
                            idRespostas.append(NAO_RESPONDEU)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
            elif key == "metadata":
                for (chave,valor) in valorData[key]["contact"].items():
                    jsonCandidato[chave] = valor['value']     
            else:
                jsonCandidato[key] = value

        jsonCandidato["idRespostas"] = idRespostas
        jsonCandidato["idPerguntas"] = idPerguntas    

        jsonCandidato = changeCandidato(jsonCandidato)

        data += json.dumps(jsonCandidato,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data += ", "

    

    if 'next' in temp["links"].keys():
        nextPage = temp["links"]["next"]
        return(requestPage(nextPage, data))
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
            
data = requestPage(url,data)

with open('responses.json', 'w') as file:
    file.write(data)

print("finalizado")



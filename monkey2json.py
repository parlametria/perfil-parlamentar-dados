# encoding: iso-8859-1
import keys
import requests
import json

def requestPage(pageUrl, data):
    payload = {'per_page': 100}
    request = s.get(pageUrl, params=payload)

    temp = json.loads(request.text)        
    
   
    for val in temp["data"]:
        jsonCandidato = {}
        idPerguntas = []
        idRespostas = []
        for (k,v) in val.items():
            if k == "pages":
                for elem in val[k]:
                    for e in elem['questions']:
                        idPerguntas.append(e['id'])
                        if 'choice_id' in e['answers'][0].keys():
                            idRespostas.append(e['answers'][0]['choice_id'])
                        elif 'text' in e['answers'][0].keys():
                            idRespostas.append(e['answers'][0]['text'])
                        else:
                            idRespostas.append('0')
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
            elif k == "metadata":
                for (c,va) in val[k]["contact"].items():
                    jsonCandidato[c] = va['value']     
            else:
                jsonCandidato[k] = v

        jsonCandidato["idRespostas"] = idRespostas
        jsonCandidato["idPerguntas"] = idPerguntas    
    
        jsonCandidato.pop("custom_variables", None)
        jsonCandidato.pop("logic_path", None)
        jsonCandidato.pop("page_path", None)

        jsonCandidato["nome_urna"] = jsonCandidato.pop("last_name", None)
        jsonCandidato["nome_exibicao"] = jsonCandidato.pop("first_name", None)
        jsonCandidato["genero"] = jsonCandidato.pop("custom_value", None)
        jsonCandidato["uf"] = jsonCandidato.pop("custom_value2", None)
        jsonCandidato["estado"] = jsonCandidato.pop("custom_value3", None)
        jsonCandidato["sg_partido"] = jsonCandidato.pop("custom_value4", None)
        jsonCandidato["partido"] = jsonCandidato.pop("custom_value5", None)
        jsonCandidato["cpf"] = jsonCandidato.pop("custom_value6", None)

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



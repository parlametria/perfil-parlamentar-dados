# encoding: iso-8859-1
import keys
import requests
import json

s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

# Script para pegar as respostas das surveys
#data = ""
#temp = ""
# lista contém o id das páginas
#for i in ['37769727', '38341527', '38341716', '38341742', '38341818']:
#    url = "https://api.surveymonkey.com/v3/surveys/%s/pages/%s/questions" % (keys.survey_id,i)
#    request = s.get(url)
#    temp = json.loads(request.text)
#    data += json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
    
#with open('data1.json', 'w') as file:
#    file.write(data)

url = "https://api.surveymonkey.com/v3/surveys/%s/responses/" % (keys.survey_id)

def getIds(url, listaids):
    request = s.get(url)
    temp = json.loads(request.text)
    ids = listaids 

    for (k, v) in temp.items():
        if k == "data":
            for i in v:
                ids.append(i["id"])
        
        if k == "links":
            if url == "https://api.surveymonkey.net/v3/surveys/155811540/responses/?page=8&per_page=50":
                return(ids)
            else:
                return getIds(v["next"], ids)

empty = []
print("inicia get dos ids das respostas")
ids = getIds(url, empty)
print("inicia get de respostas")
data = "["

for i in range(0,len(ids)):
    url = "https://api.surveymonkey.com/v3/surveys/%s/responses/%s/details" %(keys.survey_id, ids[i])
    request = s.get(url)
    temp = json.loads(request.text)
    data += json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
    if(i >= len(ids)):
        break
    else:
        data += ", "

data += "]"
print("salvando os dados...")        
with open('respostas.json', 'w') as file:
    file.write(data)

print("finalizado")


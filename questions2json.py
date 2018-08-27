import keys
import requests
import json
s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

# Script para pegar as respostas das surveys
data = ""
perguntas = []
temp = ""

#lista contém o id das páginas
pos = 0
for i in ['37769727', '38341527', '38341716', '38341742', '38341818']:
    url = "https://api.surveymonkey.com/v3/surveys/%s/pages/%s/questions" % (keys.survey_id,i)
    request = s.get(url)
    temp = json.loads(request.text)
    temp = temp["data"]
    for i in temp:
        i["_id_survey"] = i.pop("id")
        i.pop('position', None)
        i["texto"] = i.pop("heading")
        i["id"] = pos
        pos += 1
        perguntas.append(i)

data = json.dumps(perguntas,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
print(data)   

with open('perguntas.json', 'w') as file:
   file.write(data)
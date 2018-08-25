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

url = "https://api.surveymonkey.com/v3/surveys/%s/responses/bulk" % (keys.survey_id)

print("iniciando request")
request = s.get(url)
temp = json.loads(request.text)
data = json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

with open('responses.json', 'w') as file:
    file.write(data)

print("finalizado")


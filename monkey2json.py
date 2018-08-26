# encoding: iso-8859-1
import keys
import requests
import json

s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

url = "https://api.surveymonkey.com/v3/surveys/%s/responses/bulk" % (keys.survey_id)

print("iniciando request")
request = s.get(url)
temp = json.loads(request.text)
data = json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

with open('responses.json', 'w') as file:
    file.write(data)

print("finalizado")

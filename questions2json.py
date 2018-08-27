# encoding: iso-8859-1
import keys
import requests
import json

s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})
# Inicialização das variáveis necessárias
data = ""
perguntas = []
temp = ""
# índice da pergunta
pos = 0

# Get de todas as páginas da survey e seu conteúdo
for i in ['37769727', '38341527', '38341716', '38341742', '38341818']:
    url = "https://api.surveymonkey.com/v3/surveys/%s/pages/%s/questions" % (keys.survey_id,i)
    request = s.get(url)
    temp = json.loads(request.text)
    temp = temp["data"]
# Edita e adiciona conteúdo das perguntas em uma lista
    for elem in temp:
        elem["_id_survey"] = elem.pop("id")
        elem.pop('position', None)
        elem["texto"] = elem.pop("heading")
        elem["id"] = pos
        pos += 1
        perguntas.append(elem)

data = json.dumps(perguntas,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)   

# Salva perguntas
with open('perguntas.json', 'w') as file:
   file.write(data)
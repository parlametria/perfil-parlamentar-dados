import requests
import json
import keys


s = requests.session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

url = "https://api.surveymonkey.com/v3/collectors/%s/recipients" % (keys.collector_id)
payload = {'per_page': 1000, 'include': "survey_response_status,mail_status,custom_fields"}
request = s.get(url, params= payload)
request = json.loads(request.text)
data = json.dumps(request,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

with open('file.json', 'w') as file:
    file.write(data)


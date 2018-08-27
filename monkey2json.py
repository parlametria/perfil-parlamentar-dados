# encoding: iso-8859-1
import keys
import requests
import json

def requestPage(pageUrl, data):
    payload = {'per_page': 100}
    
    request = s.get(pageUrl, params=payload)

    temp = json.loads(request.text)        
    data += json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
    
    for (k, v) in temp.items():
        if k == "links":
            if 'next' in v.keys():
                nextPage = v["next"]
                data += ", "
                return(requestPage(nextPage, data))
            else:
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



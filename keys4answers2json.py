import keys
import requests
import json

s = requests.Session()
s.headers.update({
  "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
  "Content-Type": "application/json"
})

answers = {}

url = "https://api.surveymonkey.com/v3/surveys/%s/details" % (keys.survey_id)
request = s.get(url)
temp = json.loads(request.text)

for elem in temp['pages']:
    for e in elem["questions"]:
        choices = {}
        if "answers" in e.keys():
            for el in e["answers"]["choices"]:
                choices[el["id"]] = el["text"]
        answers[e["id"]] = choices

data = json.dumps(answers,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)   

with open('keys_answers.json', 'w') as file:
    file.write(data)
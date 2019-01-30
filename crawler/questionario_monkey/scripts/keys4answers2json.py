import sys
import keys
import requests
import json

def request_questions(url):
    print("Iniciando requisição")
    # Inicia a requisição 
    s = requests.Session()
    s.headers.update({
    "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
    "Content-Type": "application/json"
    })
    # Inicializa variáveis necessárias
    answers = {}
    request = s.get(url)
    temp = json.loads(request.text)
    # Itera sobre json de perguntas e encontra o id das respostas para cada pergunta
    for elem in temp['pages']:
        for e in elem["questions"]:
            choices = {}
            if "answers" in e.keys():
                # Mapeia id das respostas para [-2,-1,1] ou mantém o texto
                for el in e["answers"]["choices"]:
                    if el["text"] == "A FAVOR " or el["text"] == "A FAVOR" or el["text"] == " A FAVOR":
                        choices[el["id"]] = 1
                    elif el["text"] == "CONTRA":
                        choices[el["id"]] = -1
                    elif el["text"] == "NÃO SEI":
                        choices[el["id"]] = -2
                    else:
                        choices[el["id"]] = el["text"]
                    
            answers[e["id"]] = choices
    return answers

def main():
    url = "https://api.surveymonkey.com/v3/surveys/%s/details" % (keys.survey_id)
    answers = request_questions(url)
    data = json.dumps(answers,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)   

    with open('./dados/keys_answers.json', 'w') as file:
        file.write(data)
    
    print("Salvo")
    pass


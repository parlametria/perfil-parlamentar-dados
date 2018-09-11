import sys
import keys
import requests
import json

def request_questions():
    s = requests.Session()
    s.headers.update({
    "Authorization": "Bearer %s" % keys.YOUR_ACCESS_TOKEN,
    "Content-Type": "application/json"
    })
    # Inicialização das variáveis necessárias
    data = ""
    perguntas = []
    idPerguntas = {}
    temp = ""
    # índice da pergunta
    pos = 0
    print("Iniciando requisição das perguntas no survey monkey")
    # Get de todas as páginas da survey e seu conteúdo
    for i in ['37769727', '38341527', '38341716', '38341742', '38341818']:
        url = "https://api.surveymonkey.com/v3/surveys/%s/pages/%s/questions" % (keys.survey_id,i)
        request = s.get(url)
        temp = json.loads(request.text)
        temp = temp["data"]
    # Edita e adiciona conteúdo das perguntas em uma lista
        for elem in temp:
            # Remove dados desnecessários 
            elem.pop("href", None)
            elem.pop('position', None)
            # Altera nomes de variáveis
            elem["_id_survey"] = elem.pop("id")
            elem["texto"] = elem.pop("heading")
            elem["id"] = pos

            idPerguntas[elem["_id_survey"]] = pos

            # Define o tema com base no índice
            if pos < 10:
                elem["tema"] = "Meio Ambiente"
            elif pos >= 10 and pos < 20:
                elem["tema"] = "Direitos Humanos"
            elif pos >=20 and pos < 30:
                elem["tema"] = "Integridade e Transparência"
            elif pos >= 30 and pos < 38:
                elem["tema"] = "Nova Economia"
            else:
                elem["tema"] = "Transversal"
        
            pos += 1
            perguntas.append(elem)

    data = json.dumps(perguntas,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)   
    perg = json.dumps(idPerguntas,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

    return data, perg   

def main():
    data, perg = request_questions()
    # Salva perguntas
    with open('./dados/perguntas.json', 'w') as file:
        file.write(data)

    with open('./dados/id_perguntas.json', 'w') as file:
        file.write(perg)
    
    print("Dados salvos")

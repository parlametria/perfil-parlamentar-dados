import requests
import json
import datetime
from datetime import timedelta,datetime, date
import os, csv

def escreve_dados(caminho,dados):
    with open(caminho, 'w') as file:
        file.write(dados)    

def recupera_dados(caminho):
    with open(caminho) as file:
        dados = json.load(file)
    return dados

def busca_candidatos():
    s = requests.Session()
    s.encoding = 'ISO-8859-1'
    estados = [
        "AC",
        "AL",
        "AM",
        "AP",
        "BA",
        "CE",
        "DF",
        "ES",
        "GO",
        "MA",
        "MT",
        "MS",
        "MG",
        "PA",
        "PB",
        "PR",
        "PE",
        "PI",
        "RJ",
        "RN",
        "RO",
        "RS",
        "RR",
        "SC",
        "SE",
        "SP",
        "TO"
    ]

    data = "["
    for e in estados:            
        page_url = "http://interessados.divulgacao.tse.jus.br/2018/divulgacao/oficial/297/dadosdivweb/%s/%s-c0006-e000297-w.js" % (e.lower(), e.lower())
        request = s.get(page_url)
        request.encoding = 'UTF-8'
        temp = json.loads(request.text)
        data += json.dumps(temp,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)
        data += ", "

    data = data[:-2]
    data += "]"
    
    escreve_dados("eleitos.json",data)

def formata_eleitos():
    eleitos = recupera_dados("eleitos.json")

    data = "["
    json_candidato = {}
    for e in eleitos:
        for cand in e["cand"]:   
            if cand["e"] == "s":
                json_candidato["eleito"] = True
                json_candidato["nome_urna"] = cand["nm"]
                json_candidato["coligacao"] = cand["cc"]
                json_candidato["id"]  = cand["sqcand"] 
                json_candidato["uf"] = e["cdabr"]
            
                data += json.dumps(json_candidato,sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)   
                data += ", "

    data = data[:-2]
    data += "]"
    escreve_dados("eleitos1.json",data)
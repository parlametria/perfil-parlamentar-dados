import csv
import json
import codecs


def escreve_dados(caminho,dados):
    with open(caminho, 'w') as file:
        file.write(dados)    


def row_count(filename):
    with open(filename) as in_file:
        return sum(1 for _ in in_file)

csvfile = open('./dados congresso/votacoes.csv', "r", encoding="latin-1")
csvfile_copy = open('./dados congresso/votacoes.csv', "r", encoding="latin-1")
fileObject = open('./dados congresso/votacoes.csv', "r", encoding="latin-1")
    
row_count = sum(1 for row in fileObject)

names = ("id_votacao", "cpf", "voto")
reader = csv.DictReader( csvfile, names)
reader2 = list(csv.DictReader(csvfile_copy, names))

candidatos = []

for row in reader:
    candidato = {}
    cpf = ""
    if row["cpf"] == "cpf" or row["cpf"] == "NA":
        print("header")
    else:
        cpf = row["cpf"]
        candidato["cpf"] = row["cpf"]
        candidato["votacoes"] = {}
    for r in reader2:
        if cpf == r["cpf"]:
            candidato["votacoes"][r["id_votacao"]] = int(r["voto"])
    if candidato not in candidatos and candidato != {}:
        candidatos.append(candidato)

dados = json.dumps(candidatos, sort_keys=False, indent=4, separators=(',', ': '),ensure_ascii=False)

escreve_dados("votacoes.json", dados)
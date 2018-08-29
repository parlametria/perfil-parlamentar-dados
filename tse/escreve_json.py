# -- coding: latin-1 -- 
import csv
import json
import codecs


csvfile = open('./dados tratados/candidatos.csv', "r", encoding="latin-1")
jsonfile = open('candidatos.json', 'w', encoding= 'latin-1')

names = ("uf","estado","nome_candidato","nome_urna",
                               "nome_social","email","tipo_agremiacao","num_partido","sg_partido",
                               "partido", "nome_coligacao","composicao_coligacao","idade_posse",
                               "genero","grau_instrucao","raca","ocupacao","cpf","nome_exibicao")
import csv

import json


reader = csv.DictReader( csvfile, names)

jsonfile.write('[')

for row in reader:

    json.dump(row, jsonfile, ensure_ascii=False)

    jsonfile.write(',\n')

jsonfile.write(']')

# -- coding: latin-1 -- 
import csv
import json
import codecs

def row_count(filename):
    with open(filename) as in_file:
        return sum(1 for _ in in_file)


csvfile = open('./dados tratados/candidatos.csv', "r", encoding="latin-1")
jsonfile = open('candidatos.json', 'w', encoding= 'latin-1')

names = ("uf","estado","nome_candidato","nome_urna",
                               "nome_social","email","tipo_agremiacao","num_partido","sg_partido",
                               "partido", "nome_coligacao","composicao_coligacao","idade_posse",
                               "genero","grau_instrucao","raca","ocupacao","cpf","nome_exibicao")

reader = csv.DictReader( csvfile, names)

jsonfile.write('[')
last_line_number = 8370

for row in reader:
    json.dump(row, jsonfile, ensure_ascii=False)
    if last_line_number == reader.line_num:
        print("Última linha") 
    else:
        jsonfile.write(',\n')

jsonfile.write(']')

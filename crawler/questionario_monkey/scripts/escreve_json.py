import csv
import json
import codecs

def row_count(filename):
    with open(filename) as in_file:
        return sum(1 for _ in in_file)

def main():
    csvfile = open('./tse/dados tratados/candidatos.csv', "r", encoding="latin-1")
    fileObject = open('./tse/dados tratados/candidatos.csv', "r", encoding="latin-1")
    jsonfile = open('./tse/candidatos.json', 'w', encoding= 'latin-1')

    row_count = sum(1 for row in fileObject)

    names = ("uf","estado","nome_candidato","nome_urna",
                                "nome_social","email","tipo_agremiacao","num_partido","sg_partido",
                                "partido", "nome_coligacao","composicao_coligacao","idade_posse",
                                "genero","grau_instrucao","raca","ocupacao","cpf","reeleicao","nome_exibicao")

    reader = csv.DictReader( csvfile, names)

    jsonfile.write('[')
    for row in reader:
        json.dump(row, jsonfile, ensure_ascii=False)
        if row_count == reader.line_num:
            print("Última linha")
        else:
            jsonfile.write(',\n')

    jsonfile.write(']')

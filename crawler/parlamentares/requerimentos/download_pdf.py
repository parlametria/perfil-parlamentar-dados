import subprocess
import pandas as pd
import sys, os, re
import urllib.request

ids_proposicoes_filepath = sys.argv[1]
output_folderpath = sys.argv[2]

df = pd.read_csv(ids_proposicoes_filepath)

# Cria pasta se não existe
def createDirsIfNotExists(path):
    if not os.path.exists(path):
        os.makedirs(path)

for idx, row in df.iterrows():

    link = row["uri"]
    id_proposicao = str(row["id"])

    subpath = os.path.join(output_folderpath, str(id_proposicao) + '/pdf/')
    createDirsIfNotExists(subpath)
    file_name_tipo = "%s.pdf" % (id_proposicao)
    file_name = os.path.join(subpath, file_name_tipo)
    print(file_name)
    urllib.request.urlretrieve(link, file_name)

import requests, zipfile, io
import os
import sys

# Função que cria diretórios necessários 
def createFolder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print("Diretório criado")
    except OSError:
        print ('Error: Creating directory. ' +  directory)
        
def main():
    createFolder('./tse/dados candidatos/')
    createFolder('./tse/dados tratados/')
    createFolder('./dados/')

    print("Buscando dados do TSE")
    r = requests.get("http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2018.zip")
    z = zipfile.ZipFile(io.BytesIO(r.content))
    z.extractall("./tse/dados candidatos/")

    print("Buncando fotos dos candidatos")
    r = requests.get("https://drive.google.com/uc?id=1J2GZm379XB4zKSboqWrjc9etLcf5NrQV&export=download")
    z = zipfile.ZipFile(io.BytesIO(r.content))
    z.extractall("./")
    
    print("Todos os arquivos foram extraídos com êxito")

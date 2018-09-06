import requests, zipfile, io
import os

def createFolder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print("Já existe")
    except OSError:
        print ('Error: Creating directory. ' +  directory)
        

createFolder('./dados candidatos/')
createFolder('./dados tratados/')

r = requests.get("http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2018.zip")
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall("./dados candidatos/")


r = requests.get("https://drive.google.com/uc?id=1J2GZm379XB4zKSboqWrjc9etLcf5NrQV&export=download")
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall("../")

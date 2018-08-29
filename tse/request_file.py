import requests, zipfile, io

r = requests.get("http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2018.zip")
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall("./dados candidatos/")
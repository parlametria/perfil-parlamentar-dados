import subprocess
import sys
import keys4answers2json, questions2json, verifica_candidatos, escreve_json, request_file, monkey2json

# Dados TSE
request_file.main()
subprocess.call ("/usr/bin/Rscript --vanilla ./tse/cria_planilha_tratada.R", shell=True)
escreve_json.main()

# Survey Monkey
verifica_candidatos.main()
keys4answers2json.main()
questions2json.main()
monkey2json.main()
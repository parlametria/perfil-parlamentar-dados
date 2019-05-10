import sys, os, re

folderpath = sys.argv[1]

pat = r"\nsala das sessões,"

# # Cria pasta com as justificações
# def createDirsIfNotExists(path):
#     if not os.path.exists(path):
#         os.makedirs(path)

# fps = []

# for dirpath, dirnames, filenames in os.walk(folderpath):
#     for filename in filenames:
#       with open(os.path.normpath(os.path.join(dirpath,filename)), 'r', encoding = 'utf-8') as pl:
#         ProjetoDeLei = pl.read()
            
#         if re.search(pat,ProjetoDeLei):
#           justificacao = re.split(pat, ProjetoDeLei, maxsplit = 1, flags = re.IGNORECASE)[1]
                
#           with open(newPath + os.path.splitext(filename)[0] + '_jus.txt', 'w',encoding = 'utf-8') as j:
#           j.write(justificacao)
                    
# #subprocess.call("sleep.sh", shell=True)

path = folderpath + "2190310/" + "txt/2190310.txt"

with open(os.path.normpath(os.path.join(folderpath, path)), 'r', encoding = 'utf-8') as pl:
  ProjetoDeLei = pl.read()
  if re.search(pat,ProjetoDeLei):
    res = re.split(pat, ProjetoDeLei, maxsplit = 1, flags = re.IGNORECASE)[1]        
    print(res)